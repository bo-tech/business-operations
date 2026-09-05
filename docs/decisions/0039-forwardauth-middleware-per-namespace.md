---
date: 2026-09-05
---

(adr-0039)=
# ADR-0039 Copy the ForwardAuth middleware into every routed namespace

## Context and Problem Statement

Traefik resolves an HTTPRoute's `ExtensionRef` filter in the route's own
namespace — it mints `<route-ns>-<name>@kubernetescrd` without looking the
object up, and `ExtensionRef` has no namespace field to give. One
`authelia-forwardauth` existed, in `network`. Every namespace
{ref}`ADR-0026 <adr-0026>` moves needs its own copy.

## Considered Options

1. A copy in each app directory.
2. One definition, included by each namespace's `ns` directory.
3. Routes stay in `network` and reach backends by `ReferenceGrant`.
4. ForwardAuth on the Traefik entrypoint, for every route.

## Decision Outcome

Option 2, as `kubernetes/shared/authelia-forwardauth`. No consumer edits
when an app migrates. Option 1 breaks in `monitoring`, where two Flux
Kustomizations would claim one object. Option 3 moves routes away from
their apps. Option 4 cannot exempt Authelia's own login route.

## Consequences

A namespace now carries a Traefik object, inert where no route uses it —
including `recovery`, which wants the namespace and no controller. The
`ns` directory holds more than its name says.

## Related

- {ref}`adr-0026` — replace ingress-nginx with internal Traefik
