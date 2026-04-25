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

Migration from ingress-nginx
============================

The platform is migrating from ``ingress-nginx`` to
:term:`Gateway API` (HTTPRoute) as the primary routing mechanism.
The migration is incremental — ``ingress-nginx`` remains
operational until all applications are moved.

For third-party Helm charts that only produce Ingress resources,
Traefik's Kubernetes Ingress provider can be enabled as a
fallback, avoiding the need to maintain custom HTTPRoute manifests
alongside upstream charts.

.. seealso::

   :ref:`adr-0026` — decision record for the ``ingress-nginx``
   replacement strategy

   :doc:`/core-components/traefik` — controller implementation
   details
