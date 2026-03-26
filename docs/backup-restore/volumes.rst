
=========
 Volumes
=========

``volsync`` is used as the basis for backup and restore. Per volume a
combination of ``ReplicationSource`` and ``ReplicationDestination`` has to be
configured.


.. _sec-backup:

Backup
======

Backups are configured via the ``ReplicationSource`` resources. The template
``backup-volsync`` helps to generate this for a given ``PVC``. The default
schedule runs every three hours (``10 */3 * * *``). To stagger jobs, override
the schedule in an overlay with a small patch. One approach is to spread sources
across three-hour buckets starting at different hours:

.. code-block:: yaml

   patches:
     - patch: |-
         - op: replace
           path: /spec/trigger/schedule
           value: "32 */3 * * *"
       target:
         group: volsync.backube
         kind: ReplicationSource

Example: use ``0/3``, ``1/3``, ``2/3`` hour buckets with different minutes to
spread load.

To list current schedules from the cluster:

.. code-block:: shell

   kubectl get replicationsource -A \
       -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,SCHEDULE:.spec.trigger.schedule

Example kustomization for a volume restore overlay:

.. code-block:: yaml

   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization

   resources:
     - ../../base

   components:
     - ../../../../components/volume/backup-volsync
     - ../../../../components/volume/restore-volsync


Restore
=======


Cluster bootstrap
-----------------

Flux Kustomization
~~~~~~~~~~~~~~~~~~

Applications which do require volumes to be restored are configured as two
Kustomizations:

1. ``app`` is the application itself, it has a ``dependsOn`` configuration so
   that it will only deployed after the volumes have been restored.

2. ``app-volumes`` are the volumes together with the restore Jobs.

This ensures that the application is not yet running when the restore happens.


Restore
~~~~~~~

The restore itself is based on a ``ReplicationDestination`` resource which has
to be created for every volume which shall be restored. It can be added based on
the template ``restore-volsync`` as shown in the section :ref:`sec-backup`
above.

The restore process will create a ``PVC`` and a ``VolumeSnapshot`` based on the
``PVC``. The volume which shall be restored refers to the
``ReplicationDestination`` via the field ``dataSourceRef``. This way the volume
will only be provisioned with the fully restored data, all ``Pods`` which try to
use it wait until the volume is ready.


Restoring a specific snapshot
-----------------------------

By default VolSync restores the latest restic snapshot. To restore a
specific older snapshot:

1. List available snapshots with ``restic snapshots`` (see
   :ref:`sec-backup-manual-inspection`).

2. Delete the bootstrap PVC so VolSync can create a fresh one:

   .. code-block:: shell

      kubectl -n <namespace> delete pvc <bootstrap-pvc-name>

3. Patch the ``ReplicationDestination`` to select the snapshot by
   timestamp and re-trigger the restore:

   .. code-block:: shell

      kubectl -n <namespace> patch replicationdestination <name> \
          --type=merge -p '{
            "spec": {
              "restic": {"restoreAsOf": "2024-09-09T23:42:52Z"},
              "trigger": {"manual": "restore-specific-snapshot"}
            }
          }'

   The ``restoreAsOf`` field selects the latest snapshot at or before
   the given timestamp. The ``manual`` trigger value must differ from
   the previous value to start a new sync.

4. Wait for the ``ReplicationDestination`` to complete, then delete
   the application PVC so it gets re-provisioned from the new
   snapshot:

   .. code-block:: shell

      kubectl -n <namespace> delete pvc <app-pvc-name>

5. Reconcile the volumes Kustomization to recreate the application
   PVC via the populator:

   .. code-block:: shell

      flux reconcile ks <volumes-kustomization-name>


.. _sec-backup-manual-inspection:

Manual inspection
=================

The Restic CLI can be used locally, the following environment variables have to
be configured for this to work:

.. code-block:: shell

   # Prepare environment variables
   export AWS_ACCESS_KEY_ID=<YOUR-ACCESS-KEY-ID>
   export AWS_SECRET_ACCESS_KEY=<YOUR-SECRET-ACCESS-KEY>
   export RESTIC_PASSWORD=<YOUR-RESTIC-PASSWORD>
   export RESTIC_REPOSITORY=<s3:https://your-s3-host/your-bucket>

   # Use the CLI
   restic snapshots

The credentials are stored in the sops-encrypted restore secrets per
cluster. Extract them into environment variables with a one-liner:

.. code-block:: shell

   eval $(sops -d ./secrets/restic-restore-data-myapp-0.sops.yaml \
       | yq -r '.stringData | to_entries[] | "export \(.key)=\(.value)"')

Replace the file path with the restore secret for the volume you want
to inspect.

An alternative is to run a debug Pod via ``kubectl`` in the cluster by copying a
failed or completed ``Pod``:

.. code-block:: shell

   pod_name=volsync-src-backup-myapp-6vvqq
   namespace=$(kubectl get pod --all-namespaces \
       --field-selector=metadata.name="$pod_name" \
       -o jsonpath='{.items[0].metadata.namespace}')
   kubectl -n "$namespace" debug "$pod_name" \
       -it --copy-to=my-debugger --container=restic -- sh


Details can be found in the Restic documentation:
https://restic.readthedocs.io/en/stable/040_backup.html


Unlocking
---------

If a Restic repository is stuck due to locks, then it typically helps to remove
the locks:

.. code-block:: shell

   restic unlock --remove-all
