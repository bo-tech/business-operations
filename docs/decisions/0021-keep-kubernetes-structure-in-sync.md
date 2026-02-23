---
date: 2026-02-20
---

(adr-0021)=
# 0021 Keep Kubernetes structure in sync with source


## Context and Problem Statement

The `business-operations` repository is being extracted from `b-ops` to create a
reusable platform.

Should the structure from `b-ops` be kept in sync or should the structure
already be adjusted?


## Considered Options

- Keep structure in sync
- Refactor structure as we go


## Decision Outcome

Keep the structure in sync until the split out is complete.

This keeps the focus on the current goal to split out the common part and avoids
the split to be delayed due to further refactorings in the middle of the process.


### Structure to Maintain

The current structure looks roughly as follows:

```
business-operations/
  kubernetes/
    apps/                       # Layer "apps"
      database/                 # Namespace
        cloudnative-pg/         # The application
          ks.yaml               # Flux Kustomizations pointing into subfolders
          app/                  # Kustomization deploying the application
            kustomization.yaml
            ...
          ...                   # There may be further parts, e.g. a database cluster
      ...
    base-apps/                  # Layer "base-apps"
    bootstrap/                  # Initial cluster setup
    crds/                       # Custom Resource Definitions
    templates/                  # Reusable templates / components
```


### Consequences

- Neutral: Changes will most likely be needed in the future.
- Good: Sticking to the current structure for now will allow to perform the split faster.
- Good: Better understanding of the real needs after the split.
