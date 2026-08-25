---
date: 2026-04-28
---

(adr-0028)=
# ADR-0028 Read-only sidecar for git-pages public access

## Context and Problem Statement

git-pages serves all HTTP methods on a single port — including
the webhook endpoint that triggers repository clones. Public
visitors only need GET/HEAD to view static pages. How should
externally exposed git-pages traffic be restricted to read-only?

## Considered Options

1. **Gateway API method filtering** — HTTPRoute `matches` with
   `method: GET` on external routes.
2. **nginx sidecar** — proxy only GET/HEAD/OPTIONS to git-pages,
   expose a separate read-only Service.
3. **Application-level auth** — shared secret on the webhook.
   Requires upstream changes.

## Decision Outcome

Option 2. An nginx sidecar makes the deployment offer two access
modes as part of its contract: full access (internal) and
read-only (public). The filtering happens at the pod level,
independent of the gateway implementation.

Option 1 was rejected because a gateway misconfiguration or
replacement would silently remove the protection. Option 3 is
worth proposing upstream but not sufficient alone.

## Related

- {ref}`adr-0025`
- {ref}`adr-0026`
