---
date: 2024-01-13
---

(adr-0008)=
# 0008 Use Ansible to automate the cluster setup

## Context and Problem Statement

After the plain machine deployment the next step is to join the nodes and to
extract the configuration to access the cluster. More needs for automation will
most likely follow.

How should those tasks be automated?


## Decision Drivers

- Have a simple as possible start, taking into account existing experience and
  knowledge. Accept a potential future rework.
- Try to avoid state management for now.


## Decision Outcome

Start with Ansible to automate the deployment.

Ansible does cover the current needs and existing knowledge can be leveraged. It
is possible that parts or all will in the future be refactored into OpenTofu.
