---
date: 2026-09-06
---

(adr-0041)=
# ADR-0041 Serve the mirror on a hostname, not only in-cluster

## Context and Problem Statement

{ref}`ADR-0037 <adr-0037>` placed zot on a ClusterIP-only Service,
reasoning about the bootstrap cycle alone. That leaves it reachable only
from the cluster hosting it — but the squid proxy it replaces for image
pulls ({ref}`ADR-0035 <adr-0035>`) is a site service used by cluster-exp
and acceptance, and the `registry-mirror` module is written for nodes
that do not run the platform. Neither can reach a ClusterIP.

## Considered Options

1. **ClusterIP only** — the status quo; other clusters keep pulling
   through the proxy or direct.
2. **A LoadBalancer address** from the cilium pool.
3. **An HTTPRoute on the internal Gateway**, like any other app.

## Decision Outcome

Option 3, at `mirror.k0s.lab.bo-tech.de`.

zot speaks ordinary HTTP, so it needs no address of its own: the
internal Gateway and the `all.k0s.lab.bo-tech.de` wildcard already
exist. `mirror` rather than `registry` because this is a pull-through
cache and not the estate's registry, and rather than `cache` because
that name belongs to the proxy — the split in ADR-0035 is proxy for
everything else, mirror for images.

The route is a component of the `registry` base app, so a site opts in.

## Consequences

Supersedes ADR-0037's "nothing exposed on any interface". Exposure is
LAN-wide and anonymous, which the read-only access control makes safe:
the mirror serves public upstream image data and takes no writes.

Consumers now depend on Traefik being up. The hosting cluster does not —
it keeps the pinned ClusterIP, so its bootstrap path is unchanged, and
whether that address stays static is a separate question.

## Related

- {ref}`ADR-0035 <adr-0035>` — the proxy split this restores the reach of.
- {ref}`ADR-0037 <adr-0037>` — the placement this amends.
