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

.. seealso::

   :ref:`adr-0038`

Pointer: https://hajimari.io/
