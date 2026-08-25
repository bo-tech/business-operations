---
date: 2026-03-12
---

Superseded by [ADR-0025](0025-external-exposure-via-traefik-gateway-api.md)
once internal Traefik is deployed.

(adr-0024)=
# ADR-0024 Forgejo SSH via ingress-nginx TCP passthrough

## Context and Problem Statement

Forgejo needs SSH access for git operations. The cluster uses a single
ingress IP (`cluster_ingress_ip`) via Cilium LB IPAM. Port 22 is unused
on that IP.

## Considered Options

1. **ingress-nginx `controller.tcp` passthrough** — map port 22 on the
   shared ingress to `code/forgejo-ssh:22`. Simple, but couples
   ingress-nginx config to the Forgejo service. If Forgejo is not
   deployed, the controller logs errors (harmless).
2. **Dedicated LoadBalancer IP** — give Forgejo SSH its own Cilium L2 IP.
   Clean separation, but uses an extra IP address.
3. **Cilium sharing keys** — use `lbipam.cilium.io/sharing-key` to share
   the ingress IP across services in different namespaces. Cleanest
   Kubernetes-native approach, but requires cross-namespace annotations on
   both services.

## Decision Outcome

Option 1: TCP passthrough in ingress-nginx. The log noise when Forgejo is
absent is acceptable because Forgejo is intended as a standard platform
component. This approach will be replaced when the platform migrates to
Gateway API, which handles TCP routes natively.
