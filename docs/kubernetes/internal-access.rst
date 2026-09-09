.. _sec-internal-access:

=================
 Internal access
=================

Internal access exposes services within the cluster network,
protected by :doc:`/core-components/authelia` for authentication
and authorization. This is the default ingress path for
cluster-internal applications.

Authentication
==============

Internal routes use :term:`ForwardAuth`: the reverse proxy sends
each request to Authelia before forwarding it to the backend.
Authelia checks session cookies and access control rules, then
either allows or redirects to the login page.

In :term:`Gateway API` terms, ForwardAuth is configured as a
Traefik ``Middleware`` resource and referenced from individual
HTTPRoutes via an ``extensionRef`` filter. Routes that should
bypass authentication (e.g. Authelia's own login page) simply
omit the filter.

This differs from ``ingress-nginx`` where authentication was
global by default and individual Ingresses opted out. With
Gateway API, authentication is explicit per route.

No Ingress controller
=====================

The platform ships none, and the internal Traefik runs with
``providers.kubernetesIngress`` disabled, so an ``Ingress`` resource
is not served — it is ignored. Routing is :term:`Gateway API` only.

A third-party chart that emits only an ``Ingress`` therefore needs a
route written for it, or the chart's own if it renders one
(:ref:`ADR-0043 <adr-0043>`). A cluster that wants an Ingress
controller of its own deploys one outside the baseline; the
``ingress-nginx`` HelmRepository is still on offer under
``flux/repositories/helm``.

HTTPS backends
==============

Traefik's Gateway provider always verifies a backend's certificate.
Port inference uses the default ``ServersTransport``, and
``BackendTLSPolicy`` offers only system roots or a pinned CA; no
Service annotation turns verification off. ``ingress-nginx`` did not
verify at all, so its ``backend-protocol: HTTPS`` covered any
certificate.

An application serving HTTPS with a certificate nothing trusts
therefore needs one of three things: a certificate the system roots
accept, a ``BackendTLSPolicy`` naming its CA, or a sidecar that
terminates TLS so the route reaches plain HTTP. Unifi took the last
(:ref:`adr-0040`).

.. seealso::

   :ref:`adr-0026` — decision record for the ``ingress-nginx``
   replacement strategy

   :doc:`/core-components/traefik` — controller implementation
   details
