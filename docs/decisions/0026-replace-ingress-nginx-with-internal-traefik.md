---
date: 2026-04-25
---

(adr-0026)=
# 0026 Replace ingress-nginx with internal Traefik

## Context and Problem Statement

The cluster uses ingress-nginx as the sole internal ingress
controller. ingress-nginx is unmaintained. ADR-0025 introduced a
dedicated external Traefik instance with Gateway API for public
traffic. The internal ingress controller still needs a replacement.

## Considered Options

1. **Keep ingress-nginx** — leave it as the internal controller
   indefinitely.
2. **Internal Traefik with Gateway API only** — migrate all apps
   to HTTPRoute, disable Ingress support entirely.
3. **Internal Traefik with Gateway API as primary, Kubernetes
   Ingress as fallback** — migrate apps to HTTPRoute where
   possible, enable the Ingress provider for apps that only
   produce Ingress resources.

## Decision Outcome

Option 3. The internal Traefik instance (deployed per ADR-0025)
replaces ingress-nginx. Apps are migrated to Gateway API
(HTTPRoute) incrementally. Traefik's Kubernetes Ingress provider
can be enabled as a fallback for third-party Helm charts that only
produce Ingress resources, avoiding the need to maintain custom
HTTPRoute manifests alongside upstream charts.

Option 1 was rejected because ingress-nginx is unmaintained.
Option 2 is the ideal end state but impractical as a hard
requirement — some upstream charts only emit Ingress resources.

## Consequences

- ingress-nginx remains operational until all apps are migrated.
- ADR-0024 (Forgejo SSH via ingress-nginx TCP passthrough) is
  fully superseded once Forgejo SSH moves to a TCPRoute on the
  internal Traefik.

## Related

- {ref}`adr-0025` — two Traefik instances, external exposure
- {ref}`adr-0024` — Forgejo SSH via ingress-nginx (superseded
  by this migration)
