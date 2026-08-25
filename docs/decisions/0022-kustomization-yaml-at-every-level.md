---
date: 2026-02-28
---

(adr-0022)=
# ADR-0022 Kustomization.yaml at every directory level

## Context and Problem Statement

When extracting shared Kubernetes manifests into business-operations for
consumption by site-specific overlay repos (e.g. b-ops), consuming repos
need to reference resources across directory boundaries using relative paths.

Kustomize's load restrictor rejects references that escape the kustomization
root unless `--load-restrictor=LoadRestrictionsNone` is used. Flux's
kustomize-controller does not enforce this restriction, but local validation
with `kubectl kustomize` does.

We need a structure that allows consuming repos to include shared resources
at any granularity — an entire category (e.g. all of `kube-system`) or a
single app (e.g. just `snapshot-controller`).

## Considered Options

1. **Reference individual files** (e.g. `./snapshot-controller/ks.yaml`) —
   forces consumers to know internal file names.
2. **Single top-level kustomization per category** — consumers must take
   everything or nothing.
3. **Kustomization.yaml at every directory level** — each directory is a
   self-contained kustomize target that can be included as a resource.

## Decision Outcome

Option 3: Every directory that a consumer might want to reference gets its
own `kustomization.yaml`, even if it only lists a single resource.

Structure example:

```
base-apps/kube-system/
  kustomization.yaml              # includes snapshot-controller, cilium, ...
  snapshot-controller/
    kustomization.yaml            # includes ks.yaml
    ks.yaml                       # Flux Kustomization CRD
    app/
      kustomization.yaml          # includes helmrelease.yaml
      helmrelease.yaml
```

A consuming repo can reference at any level:

- `external/business-operations/kubernetes/base-apps/kube-system` — all apps
- `external/business-operations/kubernetes/base-apps/kube-system/snapshot-controller` — single app

This avoids load restrictor issues (directory references work cleanly), keeps
each unit self-contained, and gives consumers full flexibility without needing
to know internal file names.
