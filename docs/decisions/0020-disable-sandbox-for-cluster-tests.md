---
date: 2026-02-13
---

(adr-0020)=
# 0020 Disable sandbox for tests

## Context and Problem Statement

k0s cluster tests need container images. The NixOS test framework runs inside
the Nix build sandbox which blocks all network access.

How should tests get access to container images?

## Considered Options

1. Disable the sandbox via `--option sandbox false`
2. Pre-load all container images as Nix store paths
3. Run a container registry as a test node, pre-loaded via `additionalPaths`

## Decision Outcome

Disable the sandbox.

This is the simplest path to get cluster tests running and be able to focus on
splitting out the kubernetes layer.

## Consequences

The tests will depend on `--option sandbox false` and won't be fully
reproducible for now.

Fixing this could be done in the future by providing needed resources into the
test setup.
