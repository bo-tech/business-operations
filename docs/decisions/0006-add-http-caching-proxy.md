---
date: 2024-01-06
---

(adr-0006)=
# 0006 Add caching http proxy

## Context and Problem Statement

The CI pipelines run currently in Gitlab. As more projects have been added, more
pipelines are running and downloading again and again the same items. Especially
the Nix based builds are not yet having any caching implemented.

The question is how to easily add caching for the builds in the CI pipelines.


## Decision Outcome

Use an instance of the Squid proxy as a cache. Configure it so that it caches
mainly onto the disk.

The main rationale is that a HTTP based cache would work with all artifacts
which are served over HTTP without having to understand the specifics of the
package manager.


## Pointers

- <http://www.squid-cache.org/>
