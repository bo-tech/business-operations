==========
 Approach
==========


Credentials
===========

- Every cluster has two service accounts:

  - For the backups it uses an account which requires `RW` permissions.

  - For the restore it uses an account which only should have `RO` permissions.

- The access restrictions are enforced on the S3 side. E.g. this allows to give
  the restore of acceptance the right to read out of the production backup.



Tool selection for Volume backups
=================================

`volsync` is in use to backup and restore volumes. We switched from `k8up`
mainly because the solid snapshot support of `volsync` and due to issues with
deadlocks and piling up backup jobs in `k8up`.



Volsync specifics
=================


Drawbacks
---------

Volsync has two drawbacks at the moment:

1. It cannot backup multiple volumes into the same Restic repository. This is
   because it does not support ``--host``, ``--tag`` and ``--path``.

2. It does require a configuration per volume.

Both drawbacks are related and it seems that adding support for those is not too
hard.


Strong aspects
--------------

It does support using CSI Snapshots leading to consistent backups.



Implementation pointers
-----------------------

- `Mover implementation
  <https://github.com/backube/volsync/tree/main/controllers/mover/restic>`_

- `Restic shell script
  <https://github.com/backube/volsync/blob/main/mover-restic/entry.sh>`_

- `Helm chart
  <https://github.com/backube/volsync/tree/main/helm/volsync>`_
