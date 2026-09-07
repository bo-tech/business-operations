---
date: 2026-09-07
---

(adr-0046)=
# ADR-0046 Define the network namespace on its own

## Context and Problem Statement

{ref}`ADR-0039 <adr-0039>` put the ForwardAuth middleware into each
routed namespace's `ns` directory. `recovery` takes the `network`
namespace to run coredns and gets the middleware with it, pointing at an
Authelia that cluster does not run. The six other consumers want the
directory as it is.

## Considered Options

1. **Delete in the overlay** — recovery removes the middleware itself.
2. **Split the directory** — `ns` holds the namespace, each consumer
   adds the middleware.
3. **A separate namespace directory** — `ns` includes it beside the
   middleware.
4. **Duplicate** — recovery declares its own namespace.

## Decision Outcome

Option 3. The six consumers of `ns` stay unchanged, and recovery names
what it wants instead of removing what it does not. Option 1 copies the
directory's contents into b-ops, which breaks when `ns` gains a
resource. Option 2 makes five consumers reassemble what the platform can
ship whole. Option 4 duplicates an object that will collect labels.

## Consequences

An overlay can drop a resource with `$patch: delete`, custom resources
included. A default can therefore stay bundled: the platform does not
have to split a directory before a consumer needs the parts.

## Related

- {ref}`ADR-0039 <adr-0039>` — a ForwardAuth middleware in every routed
  namespace
