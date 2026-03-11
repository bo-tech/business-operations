======================
 Adding an application
======================

Grant access to the Ingress
============================

The default Ingress is protected via Authelia. To grant access, the new domain
has to be added into the Authelia access control configuration of the instance.

The configuration file is typically at
``kubernetes/<cluster>/apps/security/authelia/app/config/configuration.yaml``.


Add to Hajimari
================

To make an application appear in the Hajimari portal, annotate the ``Ingress``
accordingly, most often by configuring the ``ingress`` value of a Helm chart
with annotations:

.. code-block:: yaml

   ingress:
     main:
       annotations:
         hajimari.io/enable: "true"
         hajimari.io/appName: "My App"

``appName`` is optional.

Pointer: https://hajimari.io/
