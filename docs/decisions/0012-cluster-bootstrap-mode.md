---
date: 2024-05-30
---

(adr-0012)=
# 0012 Support two bootstrap modes


## Context and Problem Statement

Bringing up a new cluster can be done in two ways:

1. Restore from a backup.

2. Perform a boostrap after starting with an empty initial state.


How should those options be supported and selected?


## Decision Outcome

Use a cluster setting `cluster_bootstrap_mode` which is allowed to have one of
the following values:

- `none` - start from an empty state without any initial provisioning.

- `bootstrap` - start from an empty state and perform an initial provisioning.

- `restore` - take the state from the latest backup.
