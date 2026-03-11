.. _app-postgresql:

============
 PostgreSQL
============


Overview
========

PostgreSQL is provided based on the Operator CloudNativePG.


Pointers
--------

- Homepage of the CloudNativePG operator ---
  https://cloudnative-pg.io

- Blog post comparing PostgreSQL operators ---
  https://blog.palark.com/cloudnativepg-and-other-kubernetes-operators-for-postgresql/


Usage pattern
=============

We are using one cluster per application so that the handling of both backup and
restore is possible per application.

This also allows to update the PostgreSQL version one application at a time.

.. seealso::

   :ref:`adr-0004`


Kustomize components
--------------------

Backup and restore are provided as reusable Kustomize components from the
``business-operations`` repository:

- **``components/cnpg-cluster/backup``** --- adds ``spec.backup``, a
  ``ScheduledBackup``, and a ``cnpg-backup`` ExternalSecret.
- **``components/cnpg-cluster/restore``** --- adds ``spec.bootstrap.recovery``,
  ``spec.externalClusters``, and a ``cnpg-restore`` ExternalSecret.

Both components use Kustomize replacements to derive the S3 destination path and
server name from the ``Cluster`` resource's ``metadata.name`` and annotations.


Annotations
-----------

The ``Cluster`` resource controls revision values through two annotations:

.. code-block:: yaml

   metadata:
     annotations:
       cnpg.local/backup-revision: "v1"
       cnpg.local/restore-revision: "v1"

- **``cnpg.local/backup-revision``** --- appended to the backup ``serverName``
  (e.g. ``db-rev${cluster_revision}-v1``). Increment this when starting a new
  backup series.
- **``cnpg.local/restore-revision``** --- appended to the restore ``serverName``
  (e.g. ``db-rev${cluster_bootstrap_revision}-v1``). Set this to the revision of
  the backup you want to restore from.

A bare database cluster with these annotations looks like this:

.. code-block:: yaml

   apiVersion: postgresql.cnpg.io/v1
   kind: Cluster
   metadata:
     name: myapp-db
     annotations:
       cnpg.local/backup-revision: "v1"
       cnpg.local/restore-revision: "v1"
   spec:
     instances: 1
     storage:
       size: 5Gi


Composing backup and restore
-----------------------------

Include the components via ``components:`` in ``kustomization.yaml``. The
combination determines the mode:

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Mode
     - Components
   * - Normal operation (backup only)
     - ``backup``
   * - Restore with backup
     - ``backup`` + ``restore``
   * - Restore only (no backup)
     - ``restore``

When using the restore component, patch the bootstrap to specify the database
and owner:

.. code-block:: yaml

   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization

   resources:
     - ../../base

   components:
     - ../../../../../../../external/business-operations/kubernetes/components/cnpg-cluster/backup
     - ../../../../../../../external/business-operations/kubernetes/components/cnpg-cluster/restore

   patches:
     - target:
         kind: Cluster
       patch: |
         - op: add
           path: /spec/bootstrap/recovery/database
           value: mydb
         - op: add
           path: /spec/bootstrap/recovery/owner
           value: myuser


Backup and restore
==================


Revisions
---------

- The kubernetes cluster revision is applied so that a new cluster will never
  backup into the backups of an old cluster.

- The postgresql cluster revision has to be increased when another restore is
  performed because the operator cannot backup into an existing folder in S3.


Backup details
--------------

The backup component adds two parts to the database:

- The content of ``spec.backup`` in the ``Cluster`` resource.

- A resource of type ``ScheduledBackup`` to define the schedule.

The section `Backup and Recovery
<https://cloudnative-pg.io/documentation/1.20/backup_recovery/>`_ of the
CloudNativePG operator describes all the details about this.

The following patch shows the backup configuration added to a ``Cluster``:

.. code-block:: yaml

   backup:
     retentionPolicy: 30d
     barmanObjectStore:
       data:
         compression: bzip2
       wal:
         compression: bzip2
         maxParallel: 8
       destinationPath: s3://${cnpg_backup_base_path}
       endpointURL: ${cnpg_backup_endpoint}
       serverName: db-rev${cluster_revision}
       s3Credentials:
         accessKeyId:
           name: cnpg-backup
           key: s3_access_key_id
         secretAccessKey:
           name: cnpg-backup
           key: s3_access_key_secret

This is complemented by a ``ScheduledBackup`` provided by the same component:

.. code-block:: yaml

   apiVersion: postgresql.cnpg.io/v1
   kind: ScheduledBackup
   metadata:
     name: CLUSTER_NAME
     namespace: default
   spec:
     schedule: "@daily"
     immediate: true
     backupOwnerReference: self
     cluster:
       name: CLUSTER_NAME


Creating a cluster from a backup
---------------------------------

This is done based on the `bootstrap procedure
<https://cloudnative-pg.io/documentation/1.20/bootstrap/#bootstrap-from-a-backup-recovery>`_.

The backup concept is based on the cluster as a whole, as such it will restore
the database with the used names from the backup.

By configuring both ``database`` and ``owner`` it is possible to have a new
password be generated for the user and set within the postgresql cluster. The
password will then also be available as a kubernetes secret.

Example:

.. code-block:: yaml

   bootstrap:
     recovery:
       source: source-cluster-name
       database: mydb
       owner: myuser


Point-In-Time Recovery (PITR)
==============================

To restore a database to a specific point in time, use the
``recoveryTarget.targetTime`` field in the bootstrap configuration.

**Important:** The timestamp format must be PostgreSQL-compatible. Use the
format ``YYYY-MM-DD HH:MM:SS+00`` instead of ISO 8601 with ``Z`` suffix.

.. code-block:: yaml

   bootstrap:
     recovery:
       source: source-cluster-name
       database: mydb
       owner: myuser
       recoveryTarget:
         # Correct format - PostgreSQL accepts this
         targetTime: "2026-01-10 13:00:00+00"
         # Wrong format - PostgreSQL rejects the Z suffix
         # targetTime: "2026-01-10T13:00:00Z"

The CNPG operator converts timestamps to PostgreSQL's
``recovery_target_time`` parameter. PostgreSQL does not accept the ``Z``
timezone suffix and will fail with::

   invalid value for parameter "recovery_target_time":
   "2026-01-10 13:00:00.000000Z"


Interacting manually with the database
========================================

The databases are typically not exposed outside the cluster. This leaves the
following options to manually interact with the database:

- ``exec`` into the ``Pod`` via ``kubectl exec -it ...``.

- Use the port-forwarding of ``kubectl``, e.g. ``kubectl port-forward`` to make
  the database accessible locally.

The preferred method is to run commands directly in the Pod of the cluster so
that tooling like ``psql`` is already correctly configured.


Using pg_dump
-------------

Creating a dump manually::

   kubectl exec myapp-db-1 -- pg_dump -Fc mydb > mydb.dump

Inspecting the contents::

   pg_restore -l mydb.dump


Loading data via psql
---------------------

Loading a SQL dump into the cluster::

   gzcat backup-database.sql.gz | \
     kubectl exec -n default -i myapp-db-1 -- \
     /bin/sh -c 'PGDATABASE=mydb psql'

The idea is to pipe the data through ``kubectl exec``.
