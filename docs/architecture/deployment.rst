.. _sec-deployment-view:

============
 Deployment
============

This page covers two of the four axes described in
:ref:`sec-deployment-axes` — the environment a machine runs in, and the
point at which a run stops — together with the cheapest pairing that
answers a given question.

Substrates
==========

Bare metal or a hosted VM
   The production case. The machine is provisioned onto a booted target
   with nixos-anywhere (:ref:`ADR-0007 <adr-0007>`).

MicroVM on a NixOS host
   A guest built from the flake and installed onto a hypervisor, reusing
   spare capacity on an existing machine. The guest reaches the LAN
   through a bridge on the host, so it takes a real address and behaves
   like a separate machine. See :ref:`sec-microvm`.

A VM on a workstation
   A virtual machine on a developer's own Linux host. It needs KVM and
   nothing else, which makes it the entry point for someone who has no
   hypervisor to borrow.

No machine at all
   Work on the workload layer needs a :term:`Cluster`, not a machine.
   Any cluster serves — minikube, kind, a virtual cluster inside a host
   cluster, or one that already exists. The manifests do not depend on
   how the node beneath them was built, which is the layer separability
   :ref:`sec-architecture-constraints` requires.

.. _sec-choosing-an-environment:

Choosing an environment
=======================

Escalate only where the cheaper environment cannot answer the question.
Each environment is blind to something, and the next one exists to see
it.

Working on the machine layer
----------------------------

Changes to the NixOS modules, the k0s configuration or the hardware
assumptions. The question is whether the machine boots, whether k0s
comes up, and whether the Kubernetes API answers.

A VM on the workstation is enough, and it is ephemeral — the machine is
discarded once it has answered. Move to a microVM where the change
concerns a real address, real disks, or more than one node.

Blind to storage behaviour, to the LAN, and to anything needing a second
node.

Working on the platform layer
-----------------------------

Changes to the ansible roles, the bootstrap sequence, storage, or how
the reconciler is wired in. The question is whether a cluster comes up
from nothing and reaches a state that carries workloads.

A microVM on a hypervisor is the environment, because the run needs real
volumes and an address other machines can reach.

Working on the workload layer
-----------------------------

Changes to Kubernetes manifests, Helm values, kustomize overlays or
application configuration. The question is whether the workload deploys
and behaves.

Any cluster serves, and the reconciler is optional: manifests are
applied directly with kustomize and ``kubectl`` where the change does
not concern reconciliation itself. Reaching for a NixOS machine here
spends a bring-up on a layer the change does not touch.

Blind to the machine layer, to the storage classes a real cluster
provides, and to L2 address announcement.

Verifying the whole thing
-------------------------

The question is whether a cluster comes up from nothing on current
inputs, at the topology a real deployment uses. Nothing smaller answers
it, and it earns its cost only against a change that has already passed
the cheaper environments.

A multi-node cluster of microVMs is the environment. Configuring one is
covered in :ref:`sec-multiple-controllers`.

Environment tiers
=================

The sections above describe what a developer is changing. A deployment
is also described by how complete it is, and three tiers recur:

Local
   A cluster and enough of the platform to work on one thing. Features
   depending on the surrounding network — TLS certificates, L2 address
   announcement, backup — are left out where they are not the subject.

Full
   A complete deployment from nothing, used to verify that the bootstrap
   sequence works. Temporary.

Acceptance
   A full deployment bootstrapped from a production snapshot rather than
   from an empty state. Technically the same as a full deployment,
   differing in :ref:`bootstrap mode <adr-0012>`.
