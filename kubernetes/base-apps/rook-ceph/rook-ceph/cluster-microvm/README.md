# Rook-Ceph on microVM guests

Kustomize overlay for a multi-node cluster whose machines are microVM
guests. Everything comes from the base cluster configuration — 3 MONs,
2 MGRs, `failureDomain: host`, replication size 2 — and only the device
filter changes.

A microVM gets its ceph store as a whole raw disk, `/dev/vdb`. The base
filters on `/dev/disk/by-partlabel/disk-disk1-data`, the partition
`k0s-node-vm-disks.nix` creates, which a guest does not have. Without
this overlay rook logs the skip and comes up `Ready` with a mon, a mgr
and no OSD.

A *single* node microVM uses `cluster-single-node` instead. That overlay
serves bare metal and guests alike, so its filter accepts either shape.
