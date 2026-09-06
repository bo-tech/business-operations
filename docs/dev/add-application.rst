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

Let the chart render the ``HTTPRoute`` where it can. The route then
names the Service that same chart built, and the two cannot drift apart.
The chart has to be able to set the gateway, the hostnames and any
filter the application needs; several of the charts used here, among
them ``app-template``, produce no route at all. Write the route beside
the ``HelmRelease`` in that case, and keep in mind that its
``backendRef`` names a Service the chart derives from the release name,
which nothing checks. See :ref:`adr-0043`.

Then turn the chart's ``Ingress`` off. Most of the charts used here
default ``ingress.enabled`` to true, so a values block that is merely
removed leaves an ``Ingress`` behind on whatever host the chart defaults
to — set the flag to ``false`` instead. Read what else the chart takes
from those values before removing them: some derive the application's
own public URL from the first ingress host.


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

Helm replaces a list rather than merging it, so a site overlay that sets
``customApps`` discards every entry from the values above. An application
only one cluster runs is listed in that overlay instead, which then has
to repeat the platform's entries to keep them.

Restart Hajimari afterwards::

   kubectl -n default rollout restart deploy hajimari

The chart mounts its settings with ``subPath``, and the kubelet never
updates a ``subPath`` mount. The file the pod reads is therefore fixed at
pod creation, and Hajimari's own config watch can never see the change.

.. seealso::

   :ref:`adr-0038`

Pointer: https://hajimari.io/
