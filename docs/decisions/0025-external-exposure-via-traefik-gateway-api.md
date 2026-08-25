---
date: 2026-04-23
---

(adr-0025)=
# ADR-0025 External exposure via dedicated Traefik with Gateway API

## Context and Problem Statement

The platform needs to serve public-facing static sites on custom
domains (e.g. `www.johbo.com`). All services currently run behind a
single ingress-nginx instance on an internal IP. ingress-nginx is
unmaintained. The cluster has an external IP available via port
forwarding.

## Considered Options

1. **Extend existing ingress-nginx** — add external routes to the
   current single controller and port-forward its IP.
2. **Dedicated external ingress-nginx** — second ingress-nginx on
   its own IP for public routes.
3. **Dedicated Traefik instances with Gateway API** — external
   Traefik for public traffic, internal Traefik replacing
   ingress-nginx, each on its own IP and GatewayClass.
4. **Cilium as Gateway API controller** — enable Gateway API in the
   existing Cilium deployment.

## Decision Outcome

Option 3. Two independent Traefik deployments, each with its own
LoadBalancer IP, namespace, and GatewayClass (`external` /
`internal`). Only the external IP is port-forwarded from the
public IP.

Sharing a single controller between internal and external traffic
(option 1) means one misconfigured route or auth bypass exposes
internal services to the internet. A dedicated external instance
makes the isolation structural — the internal IP is physically
unreachable from the internet. Option 2 doubles down on an
unmaintained project. Option 4 lacks ForwardAuth for authentication
proxying (Authelia, potentially Kanidm in the future).

The external instance gets a CiliumNetworkPolicy restricting egress
to explicitly allowed backends. The internal instance carries
ForwardAuth middleware for Authelia integration. Migration is
incremental: deploy external Traefik first, then internal, migrate
apps one at a time, decommission ingress-nginx last.

## Consequences

- External domains need their own Certificate resources via
  cert-manager (Route53 DNS-01 solver, zone added to
  ClusterIssuer).
- {ref}`adr-0024` is superseded once the internal Traefik is
  deployed — TCPRoute replaces the ingress-nginx TCP passthrough
  for Forgejo SSH.
- ingress-nginx remains operational until all internal apps are
  migrated.
