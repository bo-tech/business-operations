---
date: 2026-02-28
---

(adr-0023)=
# 0023 Namespace manifests in ns/ subdirectory

## Context and Problem Statement

Base-apps categories group resources by namespace (e.g. `backup/`, `secrets/`).
Each category includes a namespace manifest and one or more apps. Placing
`namespace.yaml` at the category root forces consumers to either take the
entire category or manually exclude the namespace when picking individual apps.

## Decision Outcome

Place namespace manifests in an `ns/` subdirectory with its own
`kustomization.yaml`. The category-level kustomization references `./ns`
alongside individual apps.

```
backup/
  kustomization.yaml    # includes ./ns, ./volsync
  ns/
    kustomization.yaml  # includes namespace.yaml
    namespace.yaml
  volsync/
    ...
```

This lets consumers pick `ns/` + specific apps, or include the whole category.
Consistent with the existing pattern in `gitlab/` and `secrets/`.
