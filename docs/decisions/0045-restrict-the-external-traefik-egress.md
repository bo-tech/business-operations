---
date: 2026-09-07
---

(adr-0045)=
# ADR-0045 Restrict the external Traefik's egress

## Context and Problem Statement

{ref}`ADR-0025 <adr-0025>` said the external Traefik would get a
CiliumNetworkPolicy limiting its egress to allowed backends. None was
written, so the instance can reach any pod in the cluster, and any
namespace may attach a route to its gateway.

Such a policy has to allow two things: the kube-apiserver, which
Traefik watches for Gateway API resources, and backends that live in
other namespaces.

## Considered Options

1. **A standard `NetworkPolicy`** — names destinations by pod label,
   namespace label, or CIDR.
2. **A `CiliumNetworkPolicy`** — also names destinations by entity,
   including `kube-apiserver`.
3. **`allowedRoutes` on the gateway listener** — restricts which
   namespaces may attach a route.

## Decision Outcome

Option 2, split between the platform and the site. business-operations
allows the apiserver and DNS; a site adds a second policy naming its own
backends, and Cilium applies the union.

Option 1 fits better in every other respect but cannot name the
apiserver except by address. This one sits outside the cluster on a
virtual IP, and a wrong address stops Traefik seeing route changes with
no visible error. Cilium derives the entity from the running endpoints
instead.

Option 3 answers a different question — who may attach a route, not
where Traefik may connect — and stays open beside this.

The split follows a boundary the component already has: the TLS
listener, its certificates and every external route are site-owned.

## Consequences

- Backends are listed one by one rather than opting in through a label.
  With one backend, a general rule would be a guess; the second public
  backend is the point to revisit it.
- An external gateway with no site policy reaches nothing. That is the
  intended direction, and the Traefik page says so.
