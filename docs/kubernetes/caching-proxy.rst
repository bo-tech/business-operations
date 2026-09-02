.. _sec-caching-proxy:

===============
 Caching proxy
===============

A :term:`Node` can route its outbound fetches through a caching proxy,
so that repeated container image pulls are served locally rather than
from the internet. The proxy itself is not part of this repository — a
consuming repository supplies its URL and, where the proxy inspects
TLS, its CA certificate. :ref:`ADR-0006 <adr-0006>` records why the
platform caches at the HTTP layer.

.. code-block:: nix

   business-operations.cache-proxy = {
     enable = true;
     url = "http://cache.internal.example:3128";
     caCertificate = ./cache-ca.crt;
     noProxy = [ ".internal.example" ];
   };

The options are defined in ``nixos/modules/cache-proxy.nix`` and reached
by importing ``nixosModules.cache-proxy``. That module stands on its
own: a :term:`Node` that does not run the platform module can still use
the cache. ``url`` has no default, because the proxy is a property of
the site rather than of the platform.


What the proxy covers
=====================

The proxy environment reaches the ``k0s`` systemd unit and nothing else
on the machine. containerd runs under that unit, so container image
pulls made by the Kubernetes runtime go through the proxy. That is the
whole of what the option covers.

Nix is not covered: the nix daemon runs under its own unit, so
substitutions and flake fetches go direct. On the deployment path this
matters less than it appears, because a redeploy pushes a closure from
the store of the machine that built it rather than fetching one on the
target.

Private address ranges, ``localhost``, ``.svc`` and ``.cluster.local``
bypass the proxy by default, so a registry on a private address and any
traffic to a Kubernetes ``Service`` are reached directly. ``noProxy``
adds site-specific destinations to that list.


.. _sec-caching-proxy-ci:

CI jobs
=======

GitLab CI jobs reach the proxy by a different route. The runner sets the
proxy and certificate variables for every job it starts, so a job
inherits the cache without its repository naming it. The configuration
sits with the runner in ``kubernetes/base-apps/gitlab/gitlab/app``; the
consuming repository supplies the proxy URL as ``cache_proxy_url`` and a
``cache-ca`` ``ConfigMap`` in the ``gitlab`` namespace.

Nix is covered here, unlike on a :term:`Node`: a job container starts
with an empty store, so every closure it needs comes over the network.

What a job trusts
-----------------

The ``ConfigMap`` carries two keys, and the distinction matters:

``ca.crt``
   the proxy's CA alone.

``ca-bundle.crt``
   the public roots with that CA appended. This is what the certificate
   variables point at, because a job needs both halves — the proxy bumps
   TLS, so proxied traffic carries its signature, while a destination in
   ``no_proxy`` is reached directly and presents its real certificate.

It is a mounted file rather than something a job assembles. A
``ConfigMap`` volume is present in every container of the job pod before
anything runs, including the helper that clones; a script only ever runs
in the build container, so the clone would find nothing.

What an image must satisfy
--------------------------

There is no single way to tell a program which CA to trust, so the
runner points one variable per ecosystem at the bundle:
``SSL_CERT_FILE``, ``NIX_SSL_CERT_FILE``, ``GIT_SSL_CAINFO``,
``CURL_CA_BUNDLE`` and ``REQUESTS_CA_BUNDLE``, with
``NODE_EXTRA_CA_CERTS`` naming ``ca.crt`` because node adds it to its own
roots rather than replacing them. Each is honoured by the tools that know
it and ignored by the rest, so the list is best effort and grows when an
ecosystem turns up that none of them covers. It is not even uniform for
one tool: git ignores ``SSL_CERT_FILE`` on a Debian image while honouring
it on a Nix-built one.

Nor can the image's own trust store be relied on to carry the CA instead:
neither ``ubuntu:22.04`` nor the ``nix-flakes`` image ships
``update-ca-certificates``, and on a Nix-built image the bundle lives
read-only in the store, so writing to ``/etc/ssl/certs/ca-bundle.crt``
changes nothing that any tool reads.

An image whose tooling honours none of the variables fails, rather than
quietly going direct::

   error: unable to download 'https://...': SSL peer certificate or SSH
   remote key was not OK (60) SSL certificate OpenSSL verify result:
   self-signed certificate in certificate chain (19)

That is the intended behaviour: a job that cannot use the cache says so,
and the image gets adjusted. An ``http://`` URL is not a way around it,
because an origin that redirects to HTTPS fails at the same point.

Where the image does have a trust store and the tool to load it,
installing the CA there covers every tool in the image at once::

   cp /var/run/config/local/cache-ca/ca.crt \
      /usr/local/share/ca-certificates/cache-proxy.crt
   update-ca-certificates

Or the job can leave the proxy alone:

.. code-block:: yaml

   variables:
     http_proxy: ""
     https_proxy: ""


Confirming that a pull used the proxy
=====================================

Two things make a working proxy look like one that was never used.

``k0s ctr images pull`` does not use the proxy. On containerd 1.7 the
fetch runs in the ``ctr`` client rather than in the daemon, so it takes
the environment of the invoking shell instead of the unit's. Pull
through the CRI so that the daemon fetches, or set the proxy variables
in the shell before invoking ``ctr``.

Cilium translates the source address of traffic arriving at a
``LoadBalancer`` Service. A proxy behind one therefore logs a
cluster-internal address for a request rather than the address of the
:term:`Node` that made it, and filtering its log by the Node's own
address returns nothing.


.. _sec-caching-proxy-truncation:

Truncated entries from a CDN 304
================================

A proxy that revalidates a stored entry can truncate it. Where the
origin is a CDN that answers the conditional request with ``304 Not
Modified`` and a ``Content-Length: 0`` header, squid merges that length
into the entry it holds, and the entry then serves short. Observed on
``cdn.registry.gitlab-static.net``: a 54.8 MB image layer served as
6.29 MB, with the pull aborting on ``unexpected EOF``.

A content-addressed pull detects this, because the digest no longer
matches what arrived. A tag-based pull does not, and neither does a job
fetching a tarball over plain HTTP — there the truncated body is
accepted as the file.

`RFC 9110 section 15.4.5
<https://www.rfc-editor.org/rfc/rfc9110.html#section-15.4.5>`_ states
that a 304 carries no content, so the stored length is never the 304's
to revise. This is a defect in squid rather than in the CDN, and it is
unfixed upstream as of September 2026.

Run a squid build that drops ``Content-Length`` from the 304 header
merge. `ci-cache <https://codeberg.org/johbo/ci-cache>`_ carries the
patch as ``patches/0002-fix-drop-content-length-from-304-header-merge``;
its container image is published only to a private registry, so a
consumer builds the image locally.

The patch prevents the truncation rather than repairing it. An entry
stored short before the fix keeps serving short until the store is
cleared of it.


Trust
=====

Caching an HTTPS response means terminating the connection and
re-signing it, which is why a CA is installed into the system trust
store. Every :term:`Node` configured with one trusts that CA
system-wide, so the proxy can read and alter any proxied TLS traffic
from that Node.
Where the proxy runs, and who can reach it, are part of the platform's
trust boundary rather than an operational detail.
