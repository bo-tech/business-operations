---
date: 2024-05-30
---

(adr-0013)=
# 0013 Restore Approach

## Context and Problem Statement

Restoring volumes from a backup needs a solution so that the deployment of the
application is delayed until the restore did happen.

How should this best be implemented?

## Considered Options

- Use Helm and its hook mechanism.
- Use a custom init container.
- Use a Job together with the dependency handling of Flux.
- Switch to a different storage which provides snapshots and clones, so that the
  Volume Provisioner of Volsync can be used.

## Decision Outcome

The dependency handling of Flux does wait until Job did complete.

The waiting for a specific status of the ReplicationDestination object is
implemented in a Job by using `kubectl`. The volume setup and restore is
installed via a dedicated Flux Kostomization so that the dependency handling of
Flux can be leveraged.
