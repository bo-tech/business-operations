.. _app-traefik:

=========
 Traefik
=========

Traefik is the :term:`Gateway API` controller for both external
and internal traffic, replacing ``ingress-nginx``.

Instances
=========

Two independent Traefik deployments run in the cluster:

.. list-table::
   :header-rows: 1

   * - Instance
     - Namespace
     - GatewayClass
     - Purpose
   * - ``traefik-external``
     - ``network-external``
     - ``external``
     - Public-facing traffic
   * - ``traefik-internal``
     - ``network``
     - ``internal``
     - Cluster-internal traffic

Each instance has its own LoadBalancer IP. The external IP is the
only one port-forwarded from the public address.

Instance isolation
==================

Traefik hardcodes its Gateway API controller name
(``traefik.io/gateway-controller``). Without further
configuration, both instances would reconcile all GatewayClasses
and serve each other's routes.

Each instance uses a ``labelSelector`` on the Gateway API
provider to scope it to its own GatewayClass. The label
``local/gateway-role`` distinguishes the two::

   # In each instance's values.yaml
   providers:
     kubernetesGateway:
       labelSelector: local/gateway-role=external

   gatewayClass:
     labels:
       local/gateway-role: external

.. note::

   The Helm chart's ``values.yaml`` comments show
   ``labelselector`` (lowercase), but the JSON schema and Go
   template require ``labelSelector`` (camelCase).

Cross-namespace TLS
===================

The internal instance references the wildcard TLS certificate
from the ``cert-manager`` namespace. Gateway API requires a
``ReferenceGrant`` for cross-namespace secret access. This
grant is scoped to allow only Gateways in the ``network``
namespace to reference Secrets in ``cert-manager``.

The external instance avoids this by keeping its certificates
in its own namespace.

Serving an additional certificate
=================================

A Gateway listener serves a single certificate per SNI. Stacking
several ``certificateRefs`` on one hostname-less listener does *not*
make Traefik SNI-select among them — it serves the first (the
wildcard) and falls back to its self-signed ``TRAEFIK DEFAULT CERT``
for any SNI the wildcard does not cover.

To serve a domain outside the wildcard (e.g. a separately delegated
domain), add a dedicated listener with its own ``hostname`` and
certificate, alongside the wildcard listener::

   gateway:
     listeners:
       websecure:
         port: 8443
         protocol: HTTPS
         certificateRefs:
           - name: wildcard-tls-secret
             namespace: cert-manager
       websecure-example:
         port: 8443
         hostname: "*.example.org"
         protocol: HTTPS
         certificateRefs:
           - name: example-org-tls
             namespace: cert-manager

The more specific listener ``hostname`` wins SNI selection, so its
certificate is served. Point the ``HTTPRoute`` at the new listener
with ``sectionName``.

Adding a route
==============

Create an ``HTTPRoute`` in the application's namespace,
referencing the appropriate Gateway::

   apiVersion: gateway.networking.k8s.io/v1
   kind: HTTPRoute
   metadata:
     name: my-app
     namespace: my-namespace
   spec:
     parentRefs:
       - name: internal
         namespace: network
     hostnames:
       - my-app.example.com
     rules:
       - backendRefs:
           - name: my-app
             port: 80

Authentication
==============

The internal Traefik instance uses a ``ForwardAuth`` middleware to
delegate authentication to :ref:`app-authelia`. It is defined once, in
``kubernetes/shared/authelia-forwardauth``, and each namespace's ``ns``
directory includes it — Traefik resolves an ``ExtensionRef`` filter in
the route's own namespace, so a namespace without its own copy cannot
serve a protected route. See :ref:`adr-0039`.

Authelia's Traefik-specific endpoint (``/api/authz/forward-auth``)
handles the redirect flow. Unlike nginx where the proxy constructs
the auth redirect, Traefik delegates the redirect to Authelia —
the ``authelia_url`` query parameter tells Authelia its own
external URL.

Routes that require authentication add the middleware as an
``ExtensionRef`` filter:

.. literalinclude:: ../../kubernetes/apps/network/echo-server/app/httproute.yaml
   :language: yaml
   :start-after: [docs-forwardauth-filter]
   :end-before: [docs-forwardauth-filter]
   :dedent:

Pointers
========

- Traefik documentation — https://doc.traefik.io/traefik/
- Gateway API specification — https://gateway-api.sigs.k8s.io/
- Helm chart — https://github.com/traefik/traefik-helm-chart

.. seealso::

   :ref:`sec-external-access`,
   :ref:`sec-internal-access` — conceptual networking docs

   :ref:`adr-0025`, :ref:`adr-0026` — related decision records
