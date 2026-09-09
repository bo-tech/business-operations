.. _sec-platform-layers:

=================
 Platform layers
=================

The platform is three things at once, and a consumer meets each of them
differently. Naming them apart is what stops a consumer restating what
the platform already knows.

Core platform
=============

What makes a :term:`Cluster` this platform's rather than any other:
:term:`k0s` on NixOS, Cilium for the pod network, rook-ceph for
storage, :term:`Gateway API` through :term:`Traefik` for routing, the
backup and restore concept, certificate handling, and central
authentication.

The platform is opinionated here and offers no second choice. A consumer
does not select from this layer — it supplies **settings**: addresses,
host names, network ranges, the domain.

Components
==========

Infrastructure a :term:`Cluster` may run and may equally do without —
the pull-through registry mirror, the caches. They serve the cluster
rather than the people using it, and a cluster without them still
works.

A consumer turns each one **on or off**.

Application catalog
===================

The applications the platform prepares to run on itself, each carrying
its conventions for storage, backup, routing and authentication.

This layer is a library. A consumer **selects** from it, and configures
what it takes.

What the layers are for
=======================

A consumer restates neither composition nor ordering. Both belong to the
layer that knows them, and a consumer that repeats them holds a copy
that drifts — the platform's list moves and nothing reports that the
copy did not. See :ref:`ADR-0030 <adr-0030>`.

The layers exist because one interface cannot serve all three. Offering
the core as a menu would promise a choice of CNI that does not exist,
and would hand every consumer an ordering problem the platform has
already solved. Offering the catalog as all-or-nothing would deny that a
site runs one application and not another.

Capabilities and their providers
================================

The core layer requires capabilities rather than implementations: block
and file storage, a service address, a pod network, a backup target.
rook-ceph and Cilium are what provide them on every :term:`Substrate`
the platform deploys to today, where each capability is its own.

A :term:`Cluster` the platform did not build already provides some of
them, and binding a capability to what is there rather than deploying a
provider for it is the same kind of decision one level up — the axis
:ref:`sec-deployment-axes` names for a machine, asked of a cluster.
Keeping each capability distinct in the core layer is what leaves room
for that. No provider mechanism exists yet.

Layers are interfaces, not directories
======================================

The layer an application belongs to is decided by how a consumer meets
it, not by where it sits in the tree. The directory structure predates
this distinction and does not yet reflect it, so an application may be
filed away from the layer it belongs to until it is moved.
