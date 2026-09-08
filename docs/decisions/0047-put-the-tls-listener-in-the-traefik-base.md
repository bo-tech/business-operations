---
date: 2026-09-08
---

(adr-0047)=
# ADR-0047 Put the internal Traefik's TLS listener in the base

## Context and Problem Statement

`base-apps/network/traefik` was written for cluster-0 and reaches only
that far. It ships one listener — HTTP on 8000 — while the `websecure`
listener naming `wildcard-tls-secret` sits in cluster-0's site overlay,
and it hard-wires the git-pages Gateway with an
`lbipam.cilium.io/ips: "${cluster_git_pages_ip}"` service annotation.
demo-ops has to lose ingress-nginx and has no second address to give
that variable, and no HTTPS unless it writes cluster-0's overlay a
second time.

## Considered Options

1. **Leave the base as it is** — each consumer adds the TLS listener in
   a site overlay of its own.
2. **TLS in the base, git-pages a component** — the base serves HTTPS;
   cluster-0 selects git-pages.
3. **Both optional as components** — the base ships the HelmRelease
   alone and every consumer selects what it wants.

## Decision Outcome

Option 2. A consumer that includes the directory gets an internal
Traefik that serves, which is what makes it a baseline rather than a
starting point. Option 1 leaves the baseline unusable without
per-cluster work — the condition that blocked demo-ops in the first
place. Option 3 lets a consumer select a Traefik with no HTTPS
listener, which nothing wants.

git-pages stays optional because it is genuinely one cluster's: a
second LoadBalancer address, a Gateway, and an entrypoint for a service
demo-ops does not run.

## Consequences

- cluster-0's site overlay keeps only `bornhold.name` and its timeout.
- A consumer supplies `wildcard-tls-secret` in `cert-manager` and a
  ReferenceGrant there admitting Gateways from `network`. The base
  names the secret; it can ship neither, because both live in a
  namespace the site owns through the `certificates-restore` path
  patch. The ReferenceGrant is therefore shared rather than duplicated,
  in `kubernetes/shared/gateway-tls-referencegrant`.
- A consumer that forgets the ReferenceGrant gets a Gateway that does
  not become `Programmed`, rather than a message naming what is
  missing.
- `cluster_git_pages_ip` is read only by the component that needs it.

## Related

- {ref}`ADR-0025 <adr-0025>` — two Traefik instances, external exposure
- {ref}`ADR-0026 <adr-0026>` — replace ingress-nginx with internal
  Traefik
- {ref}`ADR-0046 <adr-0046>` — a shared directory a consumer includes
  by name
