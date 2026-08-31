---
date: 2026-08-31
---

(adr-0032)=
# ADR-0032 The caching proxy is a module of its own

## Context and Problem Statement

The platform offered the proxy as `custom.business-operations.dev.proxy`,
whose config sits under `mkIf cfg.enable`. The six lab hosts that pull
through the cache never import the platform module, so the option was
unreachable for them, and the private overlay grew a second module,
`ci-cache-proxy.nix`, doing the same job with the URL and CA hardcoded.
One capability, two implementations, no source of truth.

## Considered Options

1. **Keep the platform option** and move the lab hosts onto it — they
   would have to adopt the whole platform module, which mandates the
   node's role, address and gateway and takes over networking, users
   and the k0s role.
2. **Keep the overlay module** — the public example repository cannot
   import from a private one, so the public tier would have no
   mechanism.
3. **A standalone module in the platform**, parameterised and
   importable on its own.

## Decision Outcome

Option 3. The two mechanisms served different host populations rather
than the same one twice, and only a module independent of
`business-operations.enable` reaches both. `url` carries no default
because the proxy is a property of the site and this repository is
public.

## Consequences

`ci-cache-proxy.nix` retires and its six hosts import
`nixosModules.cache-proxy`. A node that is not a platform node can use
the cache, which is what tiers beyond acceptance will need.
