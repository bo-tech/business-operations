====================
 Installation of k0s
====================


Vision
======

``k0s`` is used as the main Kubernetes distribution. From the existing micro
Kubernetes distributions it has proven to bring in the least amount of
dependencies and only focus on the plain Kubernetes distribution.


Current state
=============

The aim is to run this based on NixOS as a base operating system. The
installation via :term:`k0sctl` has proven to be difficult in this scenario, so
that this setup is using :term:`k0s-nix` to deploy :term:`k0s` as part of the
NixOS installation.

:term:`Ansible` is used to automate the deployment of NixOS and the :term:`k0s`
based cluster. See ``ansible/`` regarding the playbooks.


Tests of using k0sctl on a single node cluster
===============================================

Setting up the cluster
----------------------

k0s
^^^

Using ``--force`` because of the missing integration with NixOS.

.. code-block:: shell

   k0sctl apply --config k0sctl.yaml --debug --force

Be aware: On a NixOS target host this will typically fail if there is no systemd
service yet configured because ``k0s install`` cannot write into
``/etc/systemd/system/k0scontroller``.

On some occasions it was necessary to manually bring up the service for the
first run::

   systemctl start k0scontroller


Cilium
^^^^^^

The installation can directly use the values from the Flux enabled part of the
repository:

.. code-block:: shell

   helm install cilium cilium/cilium --version 1.14.2 \
      --namespace kube-system \
      --values=../../kubernetes/cluster-0/base-apps/kube-system/cilium/app/values.yaml

Alternatively Cilium can be bootstrapped this way::

   cilium install --version 1.14.2

The following snippet demonstrates how to construct the helm installation
command manually:

.. code-block:: shell

   helm upgrade cilium cilium/cilium --version 1.14.2 \
      --namespace kube-system \
      --reuse-values \
      --set l2announcements.enabled=true \
      --set k8sClientRateLimit.qps={QPS} \
      --set k8sClientRateLimit.burst={BURST} \
      --set kubeProxyReplacement=true \
      --set k8sServiceHost=${API_SERVER_IP} \
      --set k8sServicePort=${API_SERVER_PORT}


Backup of the cluster state
----------------------------

::

   k0sctl backup


Pointers
========

- https://k0sproject.io/
- https://docs.cilium.io/en/stable/installation/k0s/
