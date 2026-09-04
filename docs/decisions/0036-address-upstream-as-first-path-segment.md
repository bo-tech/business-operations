---
date: 2026-09-04
---

(adr-0036)=
# ADR-0036 Address each upstream registry as the mirror's first path segment

## Context and Problem Statement

{ref}`ADR-0035 <adr-0035>` puts one zot instance in front of five
upstreams — `quay.io`, `registry.k8s.io`, `ghcr.io`, `docker.io` and
`docker.gitea.com`. An OCI request carries only a repository name, so
the mirror has to be told which upstream a request means.

## Considered Options

1. **A flat namespace** — one mirror URL for every registry; zot tries
   each configured upstream in order and serves the first that answers.
2. **The registry domain as the first path segment** — the mirror is
   addressed as `/v2/<registry>/<repo>`.
3. **The `ns` query argument** — containerd already sends the namespace
   on every mirror request.

## Decision Outcome

Option 2. The upstream becomes part of the address, so what the mirror
holds is unambiguous by construction rather than resolved by trial or
inferred from a hint.

Under a flat namespace, configuration order is policy: a repository
present on two upstreams resolves to whichever is listed first, and
since zot stores by repository name the two share one local repository.
Option 3 would need no path convention and zot does not read `ns` today,
but an explicit address is preferred regardless — it does not depend on
what a client volunteers.

The cost is a `hosts.toml` per registry on every node and containerd's
`override_path`, without which containerd appends `/v2` to a path that
already carries one.

## Consequences

`override_path` is documented for registries missing the `/v2` prefix.
Using it to add a segment works because the path is then taken verbatim,
but that is outside the field's stated intent.

The namespace is containerd composing a request path. Manifests and
their digests are untouched; {ref}`ADR-0035 <adr-0035>` governs those.

## Related

- {ref}`ADR-0035 <adr-0035>` — the pull-through registry this addresses.
