========
 FluxCD
========

When testing parts of the Flux setup, it is typically advisable to first suspend
Flux, otherwise it will revert everything quickly.


Apply a kustomization manually
===============================

::

   # This will put the Kustomization resource into Kubernetes
   kubectl apply --server-side --kustomization ./apps/network/echo-server

   # This will put the HelmRelease into the cluster
   kubectl apply --server-side --kustomization ./apps/network/echo-server/app


Build Flux resources locally
=============================

With the command ``flux build`` it is possible to render resources locally for
inspection. With the parameter ``--dry-run`` it will not even try to contact the
cluster, the only drawback is that substitutions won't work.

Example::

   flux build ks cluster-base-apps \
     --path ../<cluster>/base-apps \
     --kustomization-file flux/cluster-base-apps.yaml \
     --dry-run

See ``flux build --help`` for more details about the supported parameters.

Combined with ``kfilt`` this can give a simple feedback loop::

   flux build ks cluster-base-apps \
     --path ../<cluster>/base-apps \
     --kustomization-file flux/cluster-base-apps.yaml \
     --dry-run | kfilt -i kind=ConfigMap


Variable Substitution
======================

Flux replaces ``${VAR}`` references in all managed resources using values from
``postBuild.substituteFrom``. Resources that contain literal ``${...}`` syntax
(e.g. shell scripts) will fail with ``variable not set (strict mode)``.

To exclude a resource from substitution, annotate it:

.. code-block:: yaml

   metadata:
     annotations:
       kustomize.toolkit.fluxcd.io/substitute: disabled

See `Flux post-build variable substitution
<https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution>`_
for details.


Helm
====

Running a ``HelmRelease`` manually is a bit more involved, it typically needs a
copy of the values. In a few cases the values are already available in a
separate file, so that they can be used directly.

1. Copy the values out of ``helmrelease.yaml`` into a file ``values.yaml``.

2. Install via Helm.

Example::

   helm -n network upgrade \
     --values ./apps/network/echo-server/app/values.yaml \
     echo-server bjw-s/app-template
