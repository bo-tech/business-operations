.. _sec-multiple-controllers:

======================
 Multiple Controllers
======================

A :term:`Cluster` with a single :term:`Controller` loses its control
plane along with that machine. Running several keeps the Cluster
answering when one of them goes away.

This page covers what the platform needs configured for that, and what
it costs.


How many Controllers
====================

etcd accepts a write only when a majority of its members agree, so the
count is odd and at least three. Three tolerates the loss of one
member. Two tolerate the loss of none, because one of two is not a
majority.


Configuring the machines
========================

Each :term:`Node` sets the platform options in its own NixOS
configuration:

.. code-block:: nix

   business-operations = {
     enable = true;
     role = "controller+worker";
     cluster.isLeader = false;
     cluster.multipleControllers = true;
     network = {
       address = "192.0.2.21";
       gateway = "192.0.2.1";
     };
   };

``role``
   ``controller+worker`` where the Node carries workloads too, or
   ``controller`` where the control plane is kept to itself and the
   remaining machines join as ``worker``. ``single-node`` describes a
   Cluster of one and does not apply here.

``cluster.isLeader``
   True on exactly one Node. The leader is the Node the other
   Controllers join, and the one that issues their join tokens. It
   defaults to true only for ``single-node``, so on any other role the
   choice is made explicitly.

``cluster.multipleControllers``
   True on every Node, set identically — see
   :ref:`sec-reaching-every-controller` for what it turns on.

``network.address``
   The Node's own address, distinct per Node. etcd advertises it to the
   other members, so it has to be an address they can reach.


.. _sec-reaching-every-controller:

Reaching every Controller
=========================

``cluster.multipleControllers`` enables :term:`k0s`'s node-local load
balancing: each :term:`Node` runs a proxy that fans out to the
konnectivity server on every :term:`Controller`, and the local
konnectivity agent connects to that proxy rather than to one
Controller.

Without it the apiserver cannot reach the pod network through any
Controller but one. ``kubectl exec``, ``kubectl logs`` and admission
webhooks fail there with ``No agent available``. Why this rather than a
virtual IP is in :ref:`ADR-0034 <adr-0034>`.


No single API address
=====================

k0s refuses node-local load balancing and ``spec.api.externalAddress``
together, so a :term:`Cluster` configured as above has no one address
fronting all of its :term:`Controllers <Controller>`. Everything naming
the API names a particular one: ``cluster_service_host`` in the cluster
settings, and the kubeconfig fetched during bootstrap. Losing that
Controller leaves the Cluster running and the recorded address pointing
nowhere until it is aimed at another.


Bringing the Cluster up
=======================

The playbooks are the ones a single node :term:`Cluster` uses,
described in :doc:`ansible`. What differs is the inventory, which sorts
the machines into groups:

``initial_controller``
   Exactly one host, the leader. The join tokens are generated here.

``controllers``
   The remaining :term:`Controllers <Controller>`, which join with
   those tokens.

``workers``
   :term:`Nodes <Node>` carrying workloads only. Empty where every Node
   is a ``controller+worker``.

A non-leader Controller does nothing until its join token arrives: k0s
waits on the token file, so the machine boots, sits idle, and joins
when ansible reaches it. A machine that looks stuck before that point
is behaving as configured.
