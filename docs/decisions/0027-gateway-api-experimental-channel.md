---
date: 2026-04-27
---

(adr-0027)=
# 0027 Use Gateway API experimental channel CRDs

## Context and Problem Statement

The platform uses Traefik with the Kubernetes Gateway API
provider. Traefik v3.7 unconditionally watches TLSRoute
resources, which graduated to a v1 API but are only included
in the Gateway API experimental installation channel.

Without the TLSRoute CRD installed, the Traefik Gateway
provider fails continuously with "failed to list TLSRoute",
preventing proper certificate loading and routing.

## Considered Options

1. Switch from standard to experimental CRD bundle
2. Install only the TLSRoute CRD separately
3. Stay on Traefik v3.6 and avoid the issue

## Decision Outcome

Option 1: switch to the experimental channel bundle.

The experimental channel is a superset of the standard
channel. It adds CRDs (TLSRoute, TCPRoute, UDPRoute,
BackendLBPolicy) but does not change the behavior of
existing standard resources. Installing the bundle is
safe — unused CRDs are inert.

This also unblocks future use of TLSRoute for TLS
passthrough routing (e.g. end-to-end encrypted services
where the backend terminates TLS) and TCPRoute for raw
TCP forwarding.
