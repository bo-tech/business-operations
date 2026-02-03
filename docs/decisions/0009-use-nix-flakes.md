---
date: 2024-01-13
---

(adr-0009)=
# 0009 Use Nix Flakes to split Nix configuration

## Context and Problem Statement

Various parts of the system are based on Nix in some form. The configuration is
spread around into various repositories like `b-ops`, `k0s-nix` or `nix-tryton`.

The connection of those fragments have been made based on Nix Flakes.

Should Nix Flakes be adopted as the default?


## Decision Outcome

Use Nix Flakes by default and aim to provide all parts as a Flake.

Refactor existing other repositories on an as-need bases or when they are anyway
being worked on.

Even though Flakes are considered still an experimental feature in Nix, they
already do prove to be very useful so that the risk of breaking changes is
justified.
