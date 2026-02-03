---
date: 2024-05-31
---

(adr-0014)=
# 0014 Stay with k8up for backup and restore with restic

## Context and Problem Statement

Using Volsync turned out to introduce other problems:

- It does not support multiple PVCs into one repository.
- It requires to configure many details per PVC
- It does not support the usage of tags, so that the handling of
  cluster-revisions is not cheap in terms of storage requirements

Should we stay with k8up instead?

## Decision Outcome

We stay with k8up, mainly because it easily allows to backup all PVCs out of a
namespace.

The missing support to restore the latest snapshot is solved by creating a `Job`
which runs the initial restore directly by using `restic`.
