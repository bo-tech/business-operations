---
date: 2023-09-15
---

(adr-0001)=
# 0001 Use Gitea instead of Gogs

## Context and Problem Statement

Initially Gogs was added to provide an internal Git repository server within the
cluster. A later research showed that Gitea is a fork of Gogs which does provide
a different set of features.

Should Gitea be used instead of Gogs?

## Decision Outcome

Switch to Gitea for the following reasons:

- Gitea does offer a well maintained Helm chart.
- The Helm chart does allow to auto-configure the system.
- The support to also host artifacts is an interesting feature for future
  improvements of the setup.


## Pointers

- Gitea - <https://about.gitea.com/>
- Gogs - <https://gogs.io/>
