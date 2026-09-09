---
date: 2026-09-09
---

(adr-0048)=
# ADR-0048 Bound the mirror's staging rather than persist it

## Context and Problem Statement

zot stages every platform of an image on local disk before it reaches
S3. That directory is an `emptyDir`, and the kubelet evicts the pod when
it exceeds its `sizeLimit`. This happened twice under concurrent cold
pulls. The in-flight syncs died with the pod, and the store was still
missing those images three days later.

## Considered Options

1. **A bounded `emptyDir`** — as today, with the bound derived from the
   pull set.
2. **A PersistentVolumeClaim** — a full volume fails the sync instead of
   evicting the pod.
3. **No `sizeLimit`** — the node decides when to evict.
4. **A cap on concurrent syncs.**

## Decision Outcome

Option 1. Option 4 does not exist in zot: nothing limits how many
distinct images sync at once.

zot deletes a staging directory when a sync fails, so one is left behind
only if the process dies. An `emptyDir` is destroyed with the pod, which
covers exactly that case. A PVC would keep the directory, and zot never
sweeps the staging area at startup. It would also make the mirror depend
on cluster storage, which {ref}`ADR-0037 <adr-0037>` avoided.

## Consequences

- An overrun still evicts the pod, so the bound needs a written basis and
  the eviction needs an alert.
- The basis is the all-platform size of the pull set, because sync
  fetches every platform of an index, not the one the node runs.

## Related

- {ref}`ADR-0037 <adr-0037>` — the mirror runs in the cluster and stores in S3
