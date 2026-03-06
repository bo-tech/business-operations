# Single-Node Rook-Ceph Cluster

Kustomize overlay for running Rook-Ceph on a single node. Intended
primarily for demo and development deployments.

Key differences from the base cluster configuration:

- 1 MON, 1 MGR (instead of 3/2)
- Replication size 1 with `failureDomain: osd`
- No standby MDS
- Object store disabled
