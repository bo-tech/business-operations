---
date: 2026-09-06
---

(adr-0043)=
# ADR-0043 Take the HTTPRoute from the chart where the chart offers one

## Context and Problem Statement

Every app on the internal Traefik has a hand-written `HTTPRoute` beside
its `HelmRelease`. The route's `backendRef` names a Service the chart
builds from the release name, and nothing checks that the two match. A
mismatch is quiet: the route is `Accepted` and answers 503.

Some charts render an `HTTPRoute` themselves — Forgejo, Grafana,
kube-prometheus-stack. `app-template`, used by most apps here, does not.

## Considered Options

1. **Hand-write every route.**
2. **Use the chart's route where it fits**, hand-write the rest.
3. **Replace the charts with plain manifests.**

## Decision Outcome

Option 2. A route from the chart names the Service that chart rendered,
so the two cannot drift. That is worth more than every app expressing
its route the same way.

A chart fits when it can set the gateway, the hostnames, and any filter
the app needs. Option 3 stays open for the `app-template` apps.

## Consequences

`docs/dev/add-application.rst` says the opposite and is corrected with
this record.

## Related

- {ref}`ADR-0039 <adr-0039>` — the ForwardAuth middleware a filter
  names, which a chart must be able to express.
