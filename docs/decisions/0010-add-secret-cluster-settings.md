---
date: 2024-01-28
---

(adr-0010)=
# 0010 Add secret cluster settings

## Context and Problem Statement

Some of the values which are spread across the configuration are not exactly
secrets, yet they still should be kept private in a sense that they are not
published via the repository. Those values do not need any special protection
when deployed inside of the cluster. This means they do not have to be
restricted to `Secret` resources.

Examples are:

- An email address used for the Letsencrypt configuration.
- IDs of resources like AWS keys or Zone IDs.


## Decision Outcome

Add a second object to hold "cluster settings" based on a `Secret`.

This way the data can be kept private within the repository based on the
existing SOPS workflow. The variable substitution from Flux will then inject
those values during the deployment.
