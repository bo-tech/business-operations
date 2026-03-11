===========
 Kustomize
===========


Omitting a resource
====================

When the source of resources is not in our control it may be required to omit
specific resources, e.g. a PersistentVolumeClaim from a Helm chart.


Using a strategic merge patch
------------------------------

.. code-block:: yaml

   patches:
     - target:
         annotationSelector: "config.fluxcd.io/remove-review-overlay=true"
       patch: |
         $patch: delete
         kind: Kustomization
         metadata:
           name: DOES NOT MATTER
     - patch: |
         $patch: delete
         apiVersion: v1
         kind: Namespace
         metadata:
           name: some-namespace


Using an annotation
--------------------

Adding the following annotation does lead to Kustomize ignoring this resource:

.. code-block:: yaml

   config.kubernetes.io/local-config: "true"

Details are in the related Kubernetes documentation at
https://kubernetes.io/docs/reference/labels-annotations-taints/#config-kubernetes-io-local-config.


Local execution
----------------

Some Kustomizations refer to resources outside of their base, which lead to an
error "is not in or below" when evaluating this locally.

The ``--load-restrictor`` parameter is needed to allow this::

   kubectl kustomize --load-restrictor=LoadRestrictionsNone

.. seealso::

   Related GitHub issue: https://github.com/kubernetes-sigs/kustomize/issues/1593


Pointers
========

- The ``kubectl`` guide also describes ``kustomize``:
  https://kubectl.docs.kubernetes.io/guides/

- The ``kustomize`` reference has further details:
  https://kubectl.docs.kubernetes.io/references/kustomize/
