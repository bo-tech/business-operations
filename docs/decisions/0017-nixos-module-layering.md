---
date: 2026-02-05
---

(adr-0017)=
# 0017 NixOS module layering with profiles

## Context and Problem Statement

NixOS modules in business-operations need to be organized for reuse. Users have
different needs:

- Some want fine-grained control, picking individual modules
- Some want sensible defaults without understanding every detail

How should modules be structured to serve both use cases?

## Considered Options

1. **Flat modules only** - Every module is independent, users compose them
   manually
2. **Monolithic profiles only** - Pre-composed configurations, take-it-or-leave-it
3. **Layered approach** - Tiny focused modules + profiles that compose them

## Decision Outcome

Use a layered approach with two levels:

**Tiny modules** (`nixos/modules/`) - Single-purpose, focused configurations:

```
nixos/modules/
  nix/
    flakes.nix      # Just experimental-features for flakes
    gc.nix          # Garbage collection settings
  ...
```

**Profiles** (`nixos/profiles/`) - Compose modules into common patterns:

```
nixos/profiles/
  base.nix          # imports [ ../modules/nix/flakes.nix ... ]
```

This gives users control when needed while providing convenience for common
cases. Profiles are optional - users can always import individual modules
directly.

Start with tiny modules only. Add profiles when there are 3+ modules worth
composing.
