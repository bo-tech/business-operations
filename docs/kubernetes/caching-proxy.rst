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

   custom.business-operations.dev.proxy = {
     url = "http://cache.internal.example:3128";
     caCertificate = ./cache-ca.crt;
     noProxy = [ ".internal.example" ];
   };

The options are defined in ``nixos/modules/business-operations.nix``.
The ``dev`` namespace does not limit them to a development environment;
any tier may set them.


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
Node that made it, and filtering its log by the Node's own address
returns nothing.


Trust
=====

Caching an HTTPS response means terminating the connection and
re-signing it, which is why a CA is installed into the system trust
store. Every Node configured with one trusts that CA system-wide, so
the proxy can read and alter any proxied TLS traffic from that Node.
Where the proxy runs, and who can reach it, are part of the platform's
trust boundary rather than an operational detail.
