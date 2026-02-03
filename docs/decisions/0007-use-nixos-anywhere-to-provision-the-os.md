---
date: 2024-01-13
---

(adr-0007)=
# 0007 Use `nixos-anywhere` for machine deployments

## Context and Problem Statement

The full automation of the cluster deployment does start with installing the
base operating system into the machines.

How to automate the machine setup?


## Decision Drivers

- NixOS shall be used as the base operating system.
- A machine can be a bare-metal system, a virtual machine or any sort of cloud
  based machine.


## Considered Options

- Script the installation steps based on the readme file in
  `/infrastructure/nixos`.
- Expect the base system to be there and start from the `k0s` deployment.
- Used a customized installer image and automate from there.
- Use `nixos-anywhere` to automatically install the operating system.


## Decision Outcome

`nixos-anywhere` will be used for the provisioning of the operating system into
the given machines.

This is the only option which does provide a realistic chance to have the
deployment automated independently of the machine type and with efforts which
can currently be handled.


## Consequences

- Good, because the same automation should work on any machine type.
- Good, because the existing NixOS machine definitions can be used.
- Good, because the existing layers like Nix and NixOS still work. Building via
  `nix build` stays possible and installing via plain `nixos-rebuild switch`
  stays also possible.
- Good, because the single requirement is to have a reachable machine which
  supports `kexec` to boot into a different system.


## Pointers

- <https://nix-community.github.io/nixos-anywhere/>
