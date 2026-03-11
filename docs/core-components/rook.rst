.. _app-rook:

===========
 Rook Ceph
===========

Rook is used to operate a Ceph cluster.


Ceph cluster configuration
===========================

Current setup
-------------

Currently the setup is based on the test recommendations since there is no need
for high availability yet and data restore is part of the cluster bootstrap
process already.

When expanding to 3+ nodes this should be re-considered.

Monitor
^^^^^^^

- Quorum: 1, 3, ...
- HA: 3

Manager
^^^^^^^

- Redundancy: At least two
- HA: At least two

OSDs (Object Storage Daemon)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Redundancy: At least 3
- HA: At least 3


CSI snapshotter version coupling
=================================

The Rook operator deploys CSI provisioner pods with a ``csi-snapshotter``
sidecar. The sidecar version is hardcoded per Rook release and must be
compatible with the VolumeGroupSnapshot CRDs installed by the
snapshot-controller Helm chart (Piraeus).

Both components originate from the same upstream project
(`kubernetes-csi/external-snapshotter
<https://github.com/kubernetes-csi/external-snapshotter>`_)
but are deployed independently. When upgrading either Rook or the
snapshot-controller chart, verify that the snapshotter sidecar version and the
CRD API versions match.

A mismatch causes the snapshotter informer to fail silently, blocking **all**
VolumeSnapshot operations (backups and restores).

Check the current sidecar version:

.. code-block:: bash

   kubectl get pods -n rook-ceph -l app=csi-rbdplugin-provisioner \
     -o jsonpath='{.items[0].spec.containers[?(@.name=="csi-snapshotter")].image}'

Override via operator Helm values if needed (``csi.snapshotter.tag``).


Pointers
========

- `Rook Project homepage <https://rook.io/>`_
- `Ceph documentation <https://docs.ceph.com/>`_
