---
date: 2026-08-31
---

(adr-0033)=
# ADR-0033 Options are named after the project, not `custom`

## Context and Problem Statement

The flake exposed two option conventions: `custom.business-operations.*`
for the platform module and a bare `microvm-bridge.*` for the bridge.
`custom` is no nix convention and names no owner, so two flakes that
both pick it collide; a bare top-level name risks colliding with
nixpkgs. The flake is public, and `demo-ops` and the private overlay
both import it.

## Considered Options

1. **Keep `custom.`** — generic, and modules outside the platform would
   still need a second convention.
2. **Bare top-level names** — shortest, most exposed to a later nixpkgs
   or third-party collision.
3. **The project's own name as the prefix.**

## Decision Outcome

Option 3. Every option this flake defines lives under
`business-operations.`, including modules that do not depend on the
platform module. A shared prefix states ownership; it implies no
dependency between the modules under it.

## Consequences

A breaking rename for consumers, recorded in the changelog. `dev` leaves
the proxy option in the same pass: ADR-0031's rule against encoding one
axis in another's name applies to an option as much as to a machine.
