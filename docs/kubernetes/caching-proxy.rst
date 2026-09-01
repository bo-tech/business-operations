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


What the option covers on a Node
===============================

The proxy environment reaches the ``k0s`` systemd unit and nothing else
on the machine. containerd runs under that unit, so container image
pulls made by the Kubernetes runtime go through the proxy. That is the
whole of what the option covers.

Nix is not covered on a :term:`Node`: the nix daemon runs under its own
unit, so substitutions and flake fetches go direct. On the deployment
path this matters less than it appears, because a redeploy pushes a
closure from the store of the machine that built it rather than
fetching one on the target. In a CI job it is covered, by a different
route — see :ref:`sec-caching-proxy-ci` below.

Private address ranges, ``localhost``, ``.svc`` and ``.cluster.local``
bypass the proxy by default, so a registry on a private address and any
traffic to a Kubernetes ``Service`` are reached directly. ``noProxy``
adds site-specific destinations to that list.


.. _sec-caching-proxy-ci:

CI jobs
=======

GitLab CI jobs reach the proxy by a different route. The runner sets
the proxy and certificate variables for every job it starts, so a job
inherits the cache without its repository naming it, and a new
repository needs no CI file of its own to benefit. The configuration
sits with the runner in ``kubernetes/base-apps/gitlab/gitlab/app``; the
proxy URL comes from the consuming repository as ``cache_proxy_url``,
and the CA from a ``cache-ca`` ``ConfigMap`` it supplies in the
``gitlab`` namespace.

Nix is covered here. A job container starts with an empty store, so
every closure it needs is substituted over the network, which is
exactly what the proxy holds.

What an image must satisfy
--------------------------

The proxy bumps TLS, so a job has to trust its CA — and that CA is the
whole trust set a job needs, because every proxied connection is
re-signed by it. No public root bundle is involved.

There is no single way to tell a program which CA to trust, so the
runner sets one variable per ecosystem: ``SSL_CERT_FILE``,
``NIX_SSL_CERT_FILE``, ``GIT_SSL_CAINFO``, ``CURL_CA_BUNDLE``,
``REQUESTS_CA_BUNDLE`` and ``NODE_EXTRA_CA_CERTS``. Each is honoured by
the tools that know it and ignored by the rest, so the list is best
effort and grows when an ecosystem turns up that none of them covers.
It is not even uniform for one tool: git ignores ``SSL_CERT_FILE`` on a
Debian image while honouring it on a Nix-built one.

An image whose tooling honours none of them fails, rather than quietly
going direct::

   error: unable to download 'https://...': SSL peer certificate or SSH
   remote key was not OK (60) SSL certificate OpenSSL verify result:
   self-signed certificate in certificate chain (19)

That is the intended behaviour: a job that cannot use the cache says
so. An ``http://`` URL is not a way around it, because an origin that
redirects to HTTPS fails at the same point.

There are two ways out. The image can install the CA into its own trust
store, which covers every tool in it at once and is the better answer
for an image used repeatedly::

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


Trust
=====

Caching an HTTPS response means terminating the connection and
re-signing it, which is why a CA is installed into the system trust
store. Every :term:`Node` configured with one trusts that CA
system-wide, so the proxy can read and alter any proxied TLS traffic
from that Node. A CI job container is in the same position for as long
as it runs.
Where the proxy runs, and who can reach it, are part of the platform's
trust boundary rather than an operational detail.
