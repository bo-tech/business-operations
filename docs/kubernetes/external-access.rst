.. _sec-external-access:

=================
 External access
=================

External access allows services to be reached from the public
internet. It uses a dedicated :term:`Gateway API` controller on
its own LoadBalancer IP, which is the only IP port-forwarded from
the public address.

Security model
==============

The external controller is structurally isolated from internal
traffic:

- Separate namespace, LoadBalancer IP, and :term:`GatewayClass`
- Only the external IP is port-forwarded from the public address
- No :term:`ForwardAuth` — external routes are either public or
  use application-level authentication

This means a misconfigured internal route cannot accidentally
become reachable from the internet.

How it works
============

External access uses :term:`Gateway API`:

1. A **GatewayClass** (``external``) identifies the external
   controller
2. A **Gateway** listens on ports 80 (HTTP, redirects to HTTPS)
   and 443 (HTTPS) on the external IP
3. An **HTTPRoute** in the application's namespace defines which
   hostnames and paths route to which backend services

Certificate management uses ``cert-manager`` with a Route53
DNS-01 solver. Each external domain needs its own Certificate
resource in the controller's namespace.

Exposing a service
==================

1. Create a Certificate for the domain in the external
   controller's namespace (or add the domain to an existing
   certificate)
2. Add the domain to the Gateway's ``websecure`` listener
   (via site overlay values)
3. Create an HTTPRoute referencing the ``external`` Gateway as
   parent, with the backend service as target

.. seealso::

   :ref:`adr-0025` — decision record for the external exposure
   architecture

   :doc:`/core-components/traefik` — controller implementation
   details
