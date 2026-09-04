.. _sec-registry-mirror:

==================
 Registry mirror
==================

A :term:`Node` can pull container images through a pull-through
registry instead of fetching each one from its upstream. The mirror
speaks the OCI protocol rather than caching at the HTTP layer, which is
what separates it from the :ref:`caching proxy <sec-caching-proxy>`.
Where a mirror is in use, the proxy serves everything that is not an
image pull. :ref:`ADR-0035 <adr-0035>` records the decision.

The mirror itself is not part of this repository. A consuming
repository supplies its address. The mirror must serve upstream bytes
unchanged: a mirror that rewrites manifests changes their digests, and
every digest-pinned reference then fails.


Addressing an upstream
======================

One mirror serves every upstream. The upstream registry is the first
path segment of the request:

.. code-block:: text

   http://mirror.internal.example:5000/v2/docker.io/curlimages/curl

The mirror stores each upstream under its own prefix, so two registries
offering the same repository name stay distinct. The namespace exists
in the request path only --- manifests and their digests are untouched
by it. :ref:`ADR-0036 <adr-0036>` records the decision.


Pointing containerd at it
=========================

This requires k0s 1.36 or later, which ships containerd 2. Earlier
releases run containerd 1, whose drop-ins use ``version = 2`` under
``io.containerd.grpc.v1.cri``; k0s 1.36 rejects that older shape during
its pre-flight checks.

Under k0s, containerd configuration belongs to k0s rather than to
NixOS. k0s imports every ``*.toml`` in ``/etc/k0s/containerd.d/`` into
the configuration it generates, and reloads containerd when that
directory changes. The drop-in names a directory of per-registry hosts:

.. code-block:: toml

   version = 3

   [plugins."io.containerd.cri.v1.images".registry]
   config_path = "/etc/k0s/containerd.d/certs.d"

Each upstream gets a ``hosts.toml`` under a directory named after it,
for example ``/etc/k0s/containerd.d/certs.d/docker.io/hosts.toml``:

.. code-block:: toml

   server = "https://registry-1.docker.io"

   [host."http://mirror.internal.example:5000/v2/docker.io"]
     capabilities = ["pull", "resolve"]
     override_path = true

``server`` names where containerd resolves tags that the mirror cannot
serve. ``override_path`` is required: without it containerd appends
``/v2`` to a host URL that already carries one, and the mirror answers
404.

k0s applies these imports only while ``/etc/k0s/containerd.toml``
carries its ``# k0s_managed=true`` first line. Removing that line hands
configuration management to the operator, and the imports stop being
applied.


Verifying that pulls go through it
==================================

A successful pull is not evidence on its own. containerd falls back to
the upstream when the mirror does not answer, and the pull succeeds
either way.

Read the mirror's access log to see which requests reached it, and
compare against the images the :term:`Node` holds:

.. code-block:: bash

   k0s ctr -n k8s.io images ls -q | grep -v '^sha256:'

An image the Node holds that appears nowhere in the mirror's log
bypassed the mirror.

To check that the mirror preserved upstream bytes, hash the manifest it
serves and compare the result against the digest that was requested:

.. code-block:: bash

   curl -s -H "Accept: application/vnd.oci.image.index.v1+json" \
     http://mirror.internal.example:5000/v2/docker.io/library/alpine/manifests/sha256:... \
     | sha256sum

A digest-addressed manifest hashes to the digest it was requested by,
so a mismatch means the mirror altered it.
