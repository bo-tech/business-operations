---
date: 2026-08-31
---

(adr-0034)=
# ADR-0034 Reach every konnectivity server through node-local load balancing

## Context and Problem Statement

k0s derives the konnectivity agent's server host from
`spec.api.externalAddress`, falling back to the node's own
`spec.api.address`. This repository sets only the latter, so on a three
controller cluster every agent connects to one controller and the other
two konnectivity servers get none. `kubectl exec`, `kubectl logs` and
admission webhooks fail there with `No agent available`.

## Considered Options

1. **Node-local load balancing** — a proxy on each node that fans out
   to all konnectivity servers.
2. **Control plane load balancing** — a keepalived virtual IP, named
   as `spec.api.externalAddress`.
3. **`spec.konnectivity.externalAddress`** — an address for the agent
   alone.

## Decision Outcome

Option 1. It needs no address of its own and no VRRP router ID unique
on a wire shared with other clusters. Options 2 and 3 both answer a
larger question than the one asked — a stable API address for humans
and for joining — and k0s refuses option 1 and 2 together.

## Consequences

`spec.api.externalAddress` cannot be set on a cluster that enables
this, so a single API address fronting all controllers becomes a
decision on its own merits and would supersede this record.
