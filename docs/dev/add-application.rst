======================
 Adding an application
======================

Grant access to the route
=========================

Routes are protected via Authelia. To grant access, the new domain has to be
added into the Authelia access control configuration of the instance.

The rules are in
``kubernetes/apps/security/authelia/app/config/access-control.yaml``.

A route on the internal Traefik reaches Authelia through a ForwardAuth
middleware, added to the ``HTTPRoute`` as a filter. See :ref:`app-traefik`
for the pattern.

The middleware must exist in the application's own namespace: Traefik
resolves the filter there and nowhere else. A namespace whose ``ns``
directory does not yet include ``kubernetes/shared/authelia-forwardauth``
gets a route that returns ``404``. See :ref:`adr-0039`.

Write the ``HTTPRoute`` beside the ``HelmRelease`` rather than enabling a
route through chart values, so every application expresses its route the
same way — several of the charts used here cannot produce one at all.
Note that the ``backendRef`` then names a Service the chart derives from
the release name, and nothing checks the two still agree.


Add to Hajimari
================

Hajimari discovers applications by watching ``Ingress`` resources, so an
application on an ``HTTPRoute`` is invisible to it. List it in Hajimari's
``customApps`` instead, in
``kubernetes/apps/default/hajimari/app/values.yaml``:

.. code-block:: yaml

   hajimari:
     customApps:
       - group: security
         apps:
           - name: My App
             url: https://my-app.${cluster_domain}

The group is the namespace the application runs in, which is what discovery
used. ``icon`` and ``info`` are optional.

Restart Hajimari afterwards::

   kubectl -n default rollout restart deploy hajimari

The chart mounts its settings with ``subPath``, and the kubelet never
updates a ``subPath`` mount. The file the pod reads is therefore fixed at
pod creation, and Hajimari's own config watch can never see the change.

.. seealso::

   :ref:`adr-0038`

Pointer: https://hajimari.io/
