.. _sec-deployment-axes:

=================
 Deployment axes
=================

A deployment is described along four axes: the environment the machine
runs in, the means by which its configuration reaches it, the point at
which the run stops, and the site it belongs to. The axes vary
independently, and each is expressed in one place.
:ref:`ADR-0031 <adr-0031>` records the decision.

Substrate
=========

The substrate is the environment a machine runs in — bare metal, a
hosted VM, a microVM on a NixOS host, or a VM on a workstation. It
determines what hardware the machine sees: which disks exist, and how
the network arrives.

The machine's NixOS configuration expresses it, through the hardware and
machine-class modules it imports.

Provisioning
============

Provisioning is the means by which a configuration reaches a machine. A
configuration is installed onto a booted target, built and installed
onto a hypervisor, or run straight from the flake without being
installed at all.

The machine's NixOS configuration expresses this as well, but it is a
separate axis from substrate: one substrate accepts more than one
provisioning. A QEMU virtual machine is installed into like a physical
host, or booted from the flake and discarded afterwards.

Depth
=====

Depth is the point in the stack at which a run stops. A run leaves a
machine that boots, a :term:`Cluster` that answers, a cluster with
storage and networking in place, or a cluster with its workloads
reconciled into it.

The run expresses it — the inventory, and how far the playbook sequence
is followed. Depth is a property of the run rather than of the machine:
the same machine serves a shallow run today and a deep one tomorrow.

Site values
===========

Site values are the addresses, host names, credentials and application
selection belonging to one deployment.

The consumer expresses them, never the platform. See
:ref:`sec-architecture-context`.

One axis, one home
==================

The axes are orthogonal: any depth runs on any substrate, and any site
uses any depth. A name that encodes two of them therefore describes a
combination rather than a thing, and each further combination demands
another name.

The symptom is duplication that cannot be removed. Two machines whose
only real difference is how far their runs go are one machine written
twice, and they drift — values meant to stay equal stop being equal, and
nothing reports it, because nothing declared that they should match.

A machine name states where the machine runs and what role it plays. It
does not state how far a run went, and it does not state whose
deployment it belongs to.

A machine that also runs locally
--------------------------------

A configuration meant to run on a workstation as well as on real
hardware differs on the substrate axis alone. Its role, its network
shape and everything above them stay the same.

Express it as a variant of that machine rather than as a sibling of it.
A variant overrides what the substrate forces and inherits the rest, so
the two cannot drift apart. A sibling copies everything, and drifts by
default.
