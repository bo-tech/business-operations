---
date: 2026-02-12
---

(adr-0019)=
# 0019 Start with NixOS VM tests for end-to-end testing

## Context and Problem Statement

`business-operations` needs end-to-end testing of the deployment pipeline: from
NixOS machine configuration to a working k0s cluster with applications. The test
suite should verify that the platform works as a whole, not just individual
pieces in isolation.

Several VM testing approaches exist. The NixOS builtin test framework is proven
for service-level tests but has not been validated for full cluster lifecycle
testing (airgap image loading, node readiness, application deployment). A custom
driver offers more control but requires significant upfront infrastructure work.

Which approach should be used as the starting point?


## Considered Options

1. NixOS VM tests (`testers.runNixOSTest`)
2. Custom pytest driver using the building blocks like qemu under the hood
3. microvm.nix driven from pytest


## Decision Outcome

Start with option 1: NixOS VM tests.

The builtin framework covers the immediate needs and most likely can provide
what is needed.

Some special needs may depend on more intense tweaking, like trying to test the
installer path.

The overall setup is based on NixOS configurations. This will be re-usable
across all approaches.

Network topologies (routers, DNS, DHCP, multiple VLANs) can be composed from
NixOS nodes inside the isolated VDE network. External service dependencies (e.g.
cloud DNS APIs, ACME) can be stubbed as test nodes, keeping tests deterministic
and free from flakiness or rate limiting. Only rare smoke tests against real
external services would need to leave the sandbox.


## Pros and Cons of the Options


### NixOS VM tests (`testers.runNixOSTest`)

Builtin QEMU framework with VDE networking, Python test script, nix sandbox
isolation. Proven in `nixpkgs` and also `k0s-nix`.

* Good, because fully reproducible -- everything pinned by nix, runs in sandbox
* Good, because it supports remote builders.
* Good, because integrated into `nix flake check` and CI
* Good, because airgap image bundling via `additionalPaths` could extend
  coverage to fully Ready clusters
* Neutral, because guests must be NixOS. Not a limitation currently.
* Neutral, because unclear whether airgap bundling works well enough for full
  cluster readiness (not yet validated)


### Custom pytest driver with bridge networking

Full control over QEMU flags, TAP interfaces on a real bridge, supports real
deployment workflows (nixos-anywhere, ansible playbooks).

* Good, because tests the actual deployment pipeline end-to-end
* Good, because supports non-NixOS installer phases
* Good, because real bridge networking enables overlay testing
* Bad, because requires a Linux host with KVM, no easy remote builders
* Bad, because significant infrastructure to build and maintain (bridge setup,
  dnsmasq, QEMU lifecycle, SSH management)
* Bad, because not reproducible in the nix sandbox sense


### microvm.nix driven from pytest

Lightweight VMs with virtio-optimized hypervisors, driven from pytest for more
control over VM lifecycle.

* Good, because more control than the builtin driver (dynamic memory, lifecycle
  management)
* Good, because consumes standard `nixosSystem` configurations
* Good, because supports nested MicroVMs
* Bad, because still requires building the pytest orchestration layer
