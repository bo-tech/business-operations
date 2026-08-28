---
date: 2026-08-28
---

(adr-0029)=
# ADR-0029 Follow the k0s version k0s-nix defaults to

## Context and Problem Statement

`nixos/modules/kubernetes/k0s.nix` names no k0s version. It reads
`config.services.k0s.package`, which resolves to the k0s-nix overlay's
default. Repointing the flake input from the fork branch to
`nix-community/k0s-nix` moved that default from `1.34.4+k0s.0` to
`1.35.7+k0s.0`. Should this repository name a version of its own?

## Considered Options

1. **Follow the overlay default** — name no version.
2. **Pin explicitly** — set `services.k0s.package` in the module.
3. **Expose it per site** — let each overlay choose.

## Decision Outcome

Option 1. The default is the version k0s-nix builds and tests against,
and upstream drops old versions as they age, so a pin here would name a
version out of a set that shifts under it. Option 2 puts the version in
two places that can disagree. Option 3 is already available to a site
that needs it, since `services.k0s.package` stays settable in an
overlay.

## Consequences

Moving the k0s-nix input carries a Kubernetes minor upgrade the diff
does not show. Kubernetes supports one minor per upgrade, so the pace
of input bumps is what has to be watched.

## Related

- {ref}`ADR-0009 <adr-0009>` — flakes as the pinning mechanism.
