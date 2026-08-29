A single-node Rook-Ceph cluster reaches HEALTH_OK instead of resting at
TOO_FEW_OSDS, since the cluster-wide default pool size now follows the
one OSD the overlay expects
