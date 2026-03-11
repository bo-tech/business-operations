============
 Kubernetes
============


Patching objects which have finalizers
=======================================

.. code-block:: shell

   export NAMESPACE=flux-system

   for name in $(kubectl api-resources --verbs=list --namespaced -o name \
       | xargs -n 1 kubectl get --ignore-not-found -n $NAMESPACE -o name)
   do
     kubectl -n $NAMESPACE patch --type merge $name \
         -p '{"metadata":{"finalizers":[]}}'
   done


Using kubectl debug
====================

::

   kubectl debug myapp-pod --copy-to debug \
       --set-image=myapp=busybox -it -c myapp -- sh
