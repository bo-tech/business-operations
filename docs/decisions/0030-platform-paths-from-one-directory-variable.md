---
date: 2026-08-30
---

(adr-0030)=
# ADR-0030 Roles derive the platform paths from one directory variable

## Context and Problem Statement

The helm-deploying ansible roles read HelmRelease and values files out
of this repository, naming them as paths relative to `inventory_dir`.
The defaults assume the consumer's inventory sits two directories deep.
`b-ops` matches that; `demo-ops` keeps its inventories one level
shallower and restates sixteen paths across six inventories to correct
one `../`.

## Considered Options

1. **Per-inventory overrides** — each inventory names the paths it
   needs.
2. **Consumer `group_vars`** — each consumer names the paths once.
3. **`business_operations_dir`** — the roles build the paths from a
   directory variable the consumer sets.
4. **Fixed inventory depth** — consumers place inventories where the
   defaults expect them.

## Decision Outcome

Option 3, keeping the current path as the variable's default so `b-ops`
is unaffected. Option 2 still leaves consumers restating paths the role
owns, so a path moved here has to be chased into each of them. Option 4
would make correctness rest on two repositories keeping the same
directory depth, with nothing stating that they must.
