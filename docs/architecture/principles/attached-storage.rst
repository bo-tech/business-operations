.. _sec-attached-storage:

==================
 Attached storage
==================

Most application state lives on cluster storage: a manifest requests a
volume, the cluster provisions it, and a rebuild restores it from
backup. Some data cannot work that way. A media library is measured in
terabytes, grows for years and is rarely rewritten; restoring it into a
rebuilt cluster takes longer than the rebuild is worth.

Such data is attached to the cluster rather than held by it. The volume
exists before the cluster and outlives it. The platform mounts it and
never creates it.

When a volume is attached
=========================

Attach a volume when all three hold:

- Restoring it would dominate the time a cluster rebuild takes.
- It is written once and read many times, so the application gains
  nothing from a snapshot.
- Losing the cluster must not mean losing the data.

Where any of the three fails, the volume belongs on cluster storage. A
database fails the second: it is rewritten constantly.

What the platform provides
==========================

The manifests name a claim and say nothing about the storage behind it:
no storage class, no provisioner, no capacity request that means
anything. The claim is a site value, like an address or a credential.
See :ref:`sec-architecture-context`.

The site supplies the volume, the claim bound to it, and the reclaim
policy that keeps the data when the claim goes away.

What stays on cluster storage
=============================

The database stays on cluster storage. It is small, it is written
constantly, and the cluster's volume backup covers it.

Backup
======

An attached volume is not covered by the cluster's volume backup. It is
backed up by whoever owns the storage, from the machine that holds it:
reading terabytes back through the cluster to protect them would be
slower and no safer.

See :ref:`sec-backup-restore` for what the cluster does cover.
