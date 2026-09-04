---
date: 2026-09-04
---

(adr-0037)=
# ADR-0037 Run the mirror in the cluster, seeded from the node closure

## Context and Problem Statement

{ref}`ADR-0035 <adr-0035>` chose zot but left open where it stores, where
it runs, and what must be up before the first pull. A cluster cannot pull
the image of the registry that serves its pulls, and here a rebuild starts
from a bare machine. A ClusterIP is translated by Cilium on the consuming
node, so it cannot serve that node's own Cilium pull.

## Considered Options

1. **A seed cluster** — a single-node cluster serving the mirror until the
   real cluster can, then wiped.
2. **The first node as the seed** — the mirror on that node's host network
   during bootstrap, moved in-cluster afterwards.
3. **A mirror per node** — a DaemonSet on loopback, sharing one store.
4. **One in-cluster mirror**, with the images needed before it carried in
   the node's nix closure.

## Decision Outcome

Option 4: one Deployment on a pinned ClusterIP, content in S3 with
deduplication disabled, and the images preceding it placed in the node
closure behind an option.

Carrying those images removes the need for anything to serve them, and
with it the stand-in and the exposed address that options 1 and 2 require
— the more so because the platform disables the node firewall by default.
Option 3 exposes nothing either, but loses the saving whenever the store
is cold, since every node then misses at once. S3 because a rebuild from a
bare machine leaves no alternative; deduplication off because on S3 it
writes stubs resolvable only through a cache database that dies with the
instance. The option carries no default, per
{ref}`ADR-0032 <adr-0032>`.

## Consequences

The bundle is an optimisation, not a mechanism: with it off the deploy
path is identical and only slower.

Cilium's digest is pinned in the closure as well as in its HelmRelease. A
stale bundle is harmless, but wants refreshing to stay useful.

Nothing now needs to exist before the cluster, so what stands in for the
services it needs from itself is left undecided.

## Related

- {ref}`ADR-0035 <adr-0035>` — the pull-through registry this places.
- {ref}`ADR-0036 <adr-0036>` — how an upstream is addressed on it.
