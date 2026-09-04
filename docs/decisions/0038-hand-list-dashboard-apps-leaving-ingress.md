---
date: 2026-09-04
---

(adr-0038)=
# ADR-0038 List dashboard apps by hand once they leave Ingress

## Context and Problem Statement

Hajimari discovers apps by watching Ingress resources for
`hajimari.io/*` annotations; fourteen manifests here carry one. Its
source references Gateway API nowhere, and the project is archived. So
every app {ref}`ADR-0026 <adr-0026>` moves to an HTTPRoute leaves the
dashboard as it moves.

## Considered Options

1. Accept the loss — the dashboard empties as the migration runs.
2. Hand-list each app in Hajimari's `customApps`.
3. Replace Hajimari with a dashboard that reads HTTPRoute.
4. Fork Hajimari and teach it Gateway API.

## Decision Outcome

Option 2, for now: an app gains its `customApps` entry in the same
change that gives it a route. Option 3 is the likely end state but is
not work this sprint can carry beside moving the apps.

## Consequences

The list is derived from nothing. A removed app stays on the dashboard
until someone edits it out.

## Related

- {ref}`adr-0026` — replace ingress-nginx with internal Traefik
