---
date: 2026-09-06
---

(adr-0040)=
# ADR-0040 Terminate Unifi's TLS in a sidecar

## Context and Problem Statement

Unifi's UI is HTTPS only, with a certificate the image generates itself —
`cn=UniFi`, no SAN. ingress-nginx reached it through
`backend-protocol: HTTPS`, which does not verify. Traefik's Gateway
provider has no equivalent: it verifies the backend chain either way, and
reads no annotation that would turn that off.

## Considered Options

1. Unifi serves a cert-manager certificate, through a `BackendTLSPolicy`.
2. An nginx sidecar terminates TLS; the route reaches it over HTTP.
3. Pin Unifi's own leaf in the `BackendTLSPolicy`.
4. No route — Unifi stays on its LoadBalancer.

## Decision Outcome

Option 2, following {ref}`adr-0028`. The certificate stays on the Traefik
listener, which cert-manager renews and Traefik reloads in place.

Option 1 would copy it into the Java keystore, which the image writes only
at container start — a renewal then sits unread until something restarts
the pod, and nothing here does. Option 3 has nothing to match: the
generated certificate carries no SAN. Option 4 gives up the Authelia gate,
which is the reason for the move.

## Consequences

Traefik reaches Unifi in plaintext, as it already does every other app on
the internal gateway, and the unverified hop moves onto loopback inside
the pod.

## Related

- {ref}`adr-0026` — replace ingress-nginx with internal Traefik
- {ref}`adr-0028` — read-only sidecar for git-pages
