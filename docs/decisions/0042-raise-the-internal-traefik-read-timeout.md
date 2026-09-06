---
date: 2026-09-06
---

(adr-0042)=
# ADR-0042 Raise the internal Traefik read timeout

## Context and Problem Statement

Traefik cuts a request off after 60 seconds, body included.
ingress-nginx did not: its timeout applies per read, so a slow upload
of any length went through. Apps moving to Traefik gain that limit.
Forgejo pushes git repositories and container images over HTTPS, which
can take longer.

The setting belongs to the entrypoint. A route can lower it, not raise
it.

## Considered Options

1. **Keep the 60 second default.**
2. **Disable the timeout** with `readTimeout: 0`.
3. **Set a longer finite timeout** on the internal Traefik.

## Decision Outcome

Option 3, one hour on `web` and `websecure`. That is longer than any
upload here and still drops a stalled connection, which option 2 gives
up. Under option 1 a push would break off mid-transfer, and the error
does not look like a proxy timeout.

The timeout covers every route rather than the apps that need it, unlike
the body size in {ref}`ADR-0005 <adr-0005>`. Traefik offers no per-route
setting.

## Consequences

Responses are unaffected: `writeTimeout` is unset and always was.

## Related

- {ref}`ADR-0005 <adr-0005>` — body size, set per app instead.
- {ref}`ADR-0026 <adr-0026>` — the migration this came up in.
