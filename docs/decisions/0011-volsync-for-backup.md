---
date: 2024-05-30
status: superseded by [ADR-0014](./0014-stay-with-k8up-for-backup.md)
---

(adr-0011)=
# 0011 Use Volsync for backup and restore

## Context and Problem Statement

Initially `k8up` has been chosen as a backup tool. When building the automatic
bootstrap based on the latest snapshot it turned out that `k8up` has no good
support for this use case.

Which tool should be used for automatic restore?

## Considered Options

- `k8pu` with patches to extend the functionality
- `volsync`
- `velero`

## Decision Outcome

Volsync does allow to configure both the backup and the restore on a per volume
basis. It can be ramped up in parallel to `k8up` incrementally.

Velero did look too complex still.


## Consequences

The handling of `volsync` is quite verbose compared to `k8up`. There might be a
chance to mitigate this with the tooling of Kustomize.

`volsync` only allows to backup one volume per Restic repository. We will end up
with many repositories.
