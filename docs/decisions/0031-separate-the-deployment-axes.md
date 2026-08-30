---
date: 2026-08-30
---

(adr-0031)=
# ADR-0031 Substrate, provisioning, depth and site values are separate axes

## Context and Problem Statement

A deployment is described by a NixOS configuration for the machine and
an ansible inventory for the run. In `demo-ops`, `dev-microvm` and
`demo-single-node-microvm` differ only in hostname, address, MAC and
interface id. What separates a `dev` machine from a `demo` one is its
inventory: the `dev` inventories set `skip_rook_ceph` and declare no
`cluster_path`, so the run stops after Cilium and OpenEBS. Deployment
depth is announced in machine names while living in inventories.

## Considered Options

1. **Keep the naming** — each pair stays, meaning whatever its
   inventory does.
2. **Give the dev machines their own profile** — less memory, no ceph
   volume, so the pair differs materially.
3. **Name the axes** — the machine describes substrate and
   provisioning, the run describes depth, the overlay carries site
   values.

## Decision Outcome

Option 3. The axes vary independently, so encoding one in another's
name multiplies configurations and guarantees drift — which the
identical microVM pair already shows. Option 1 keeps those duplicates.
Option 2 spends a second profile on a machine whose purpose is to be
cheap, and leaves depth in the name regardless.

## Consequences

Depth stays in the inventory until `bootstrap-existing-machines.yaml`
can stop at a named step; only then do the depth-specific inventories
retire.
