---
date: 2026-04-27
---

(adr-0027)=
# ADR-0027 Upgrade Gateway API CRDs for TLSRoute v1

## Context and Problem Statement

The platform uses Traefik with the Kubernetes Gateway API
provider. Traefik v3.7 unconditionally watches TLSRoute v1
resources. TLSRoute was promoted to v1 in Gateway API v1.5.0
— earlier versions only have v1alpha3.

Without the v1 TLSRoute CRD, the Traefik Gateway provider
fails continuously with "failed to list TLSRoute", preventing
proper certificate loading and routing.

Additionally, Traefik v3.6 only uses the first certificateRef
on a Gateway listener for SNI matching. Multiple certificate
support requires v3.7 (traefik/traefik#12590).

## Considered Options

1. Upgrade Gateway API CRDs to v1.5.1 (standard channel
   includes TLSRoute v1)
2. Stay on v1.4.0 and switch to experimental channel
   (TLSRoute v1alpha3 — insufficient for Traefik v3.7)
3. Stay on Traefik v3.6 and avoid the issue

## Decision Outcome

Option 1: upgrade Gateway API CRDs to v1.5.1 standard channel.

TLSRoute graduated to v1 and moved into the standard channel
in Gateway API v1.5.0. No need for the experimental channel.
The upgrade is backward-compatible — existing HTTPRoute,
Gateway, and GatewayClass resources are unchanged.

External Traefik pinned to v3.7.0-rc.2 via image tag override
until the Helm chart ships a stable v3.7 release.
