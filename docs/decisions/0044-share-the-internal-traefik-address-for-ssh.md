---
date: 2026-09-06
---

(adr-0044)=
# ADR-0044 Share the internal Traefik address for Forgejo SSH

Supersedes {ref}`ADR-0024 <adr-0024>`.

## Context and Problem Statement

Forgejo announces one hostname for HTTP and SSH. Moving HTTP to the
internal Traefik moved that hostname to Traefik's address, where port 22
is closed, so SSH broke. It had reached the cluster through a TCP
passthrough on the ingress-nginx address.

{ref}`ADR-0026 <adr-0026>` expected SSH to move to a TCPRoute. The
installed Gateway API is the standard channel at v1.5.1, which has none.

## Considered Options

1. **A Traefik `IngressRouteTCP`** on a new entrypoint for port 22.
2. **Share Traefik's address** with Cilium's LB IPAM.
3. **Switch the Gateway API CRDs** to the experimental channel.

## Decision Outcome

Option 2. Port 22 reaches Forgejo directly, with no proxy in the path
and no change to Traefik's entrypoints.

Option 1 fronts a protocol Traefik does not inspect, and the new
entrypoint restarts it, interrupting every internal route. Option 3
moves every Gateway API CRD on every cluster to gain one route.

## Consequences

ADR-0026 expected a TCPRoute to be what supersedes ADR-0024. The address
is shared rather than routed, and this record supersedes it instead.
