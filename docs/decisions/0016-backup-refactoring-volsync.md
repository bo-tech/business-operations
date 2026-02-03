---
date: 2024-06-23
---

(adr-0016)=
# 0016 Refactor backup and restore

## Context and Problem Statement

The backup via `k8up` was not stable, despite some fixed which have been added
into `k8up`.

Should we keep fixing up `k8up` or change the approach to a different tool?

## Considered Options

- Stay with `k8up` and keep fixing
- Back to `volsync` again

## Decision Outcome

Volsync will be used to backup and restore the cluster.

Due to the improvements and stage splits in the backup and restore there is no
pressing need anymore to support the restic tags.

Volsync does use snapshots via the CSI drivers both for the restore and for the
backup, this does ensure consistent and reliable backups. The usage of snapshots
in restore has already been proven to be valuable in the custom implementation.

There is a possibility that restoring the database clusters will also be
possible based on snapshots.
