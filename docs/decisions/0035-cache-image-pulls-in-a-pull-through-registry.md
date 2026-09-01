---
date: 2026-09-01
---

(adr-0035)=
# ADR-0035 Cache container image pulls in a pull-through registry

## Context and Problem Statement

Cluster nodes pull container images through the ci-cache squid proxy,
which SSL-bumps the connection and caches the result as an opaque HTTP
response. {ref}`ADR-0006 <adr-0006>` chose that proxy for the artifacts
CI pipelines fetch and still governs them; image pulls arrived on the
same instance later, without a record of their own.

Measured in August 2026, the proxy caches: 767 of 2394 requests hit, and
a cluster deployed from scratch took around 89 percent of its
transferred bytes from the store. Against `cdn.registry.gitlab-static.net`
it does not. Every blob comes back `TCP_REFRESH_UNMODIFIED`, a 54.8 MB
layer truncates to 6.29 MB, and the client aborts on `unexpected EOF`.

The CDN sends `Cache-Control: private, max-age=0`. An HTTP cache is
obliged to revalidate on that header, so serving these blobs from store
means overriding the origin with a refresh pattern matched against URL
shapes — for content the OCI protocol already guarantees is immutable,
because it is addressed by digest.

## Considered Options

1. **A pull-through registry for images, the proxy for the rest.**
2. **Extend the proxy** — purge the affected entries and point the
   remaining clusters at it.
3. **Harbor or Quay** — full registries offering proxy cache projects.
4. **Distribution** — the CNCF registry in mirror mode.

## Decision Outcome

Option 1, with zot as the registry.

It speaks the OCI protocol, so a digest-addressed blob is immutable by
construction and no refresh pattern has to argue the point. One instance
serves every upstream in the observed pull set — `quay.io`,
`registry.k8s.io`, `ghcr.io`, `docker.io` and `docker.gitea.com` — from
a single binary over filesystem storage, adding no database to an estate
whose clusters run from one node to twelve.

zot was ruled out in February 2026 because it rewrites Docker v2
manifests to OCI on ingestion and so changes the digest. Re-tested
against v2.1.20, that ground does not hold: `http.compat: ["docker2s2"]`
with `preserveDigest: true` serves upstream bytes unchanged on every
path, including `curlimages/curl@sha256:935d9100`, a digest this
repository has pinned for months and which no longer matches `latest`.
Both options shipped before the February reading was taken, so the
finding was a misreading of an available capability rather than a stale
reading of a missing one.

Option 2 stays defensible — the poisoning is per entry rather than a
decay, so a purge would clear what the store holds — but it repairs the
entries instead of removing the condition that produces them. Options 3
and 4 were rejected on weight and on shape respectively: Harbor and Quay
need PostgreSQL, Redis and a component set for a caching job, and
Distribution mirrors one upstream per instance, making the pull set
above five deployments.

## Consequences

The proxy stays. CI fetches arbitrary things over HTTPS and no
registry-shaped cache reaches that traffic at all, so
{ref}`ADR-0006 <adr-0006>` continues to describe it and is not
superseded. A Nix binary cache, whenever it is wanted, also belongs
there rather than here.

A node that only pulls images no longer needs the proxy's CA in its
trust store. That withdraws image traffic from a man-in-the-middle
position over every proxied TLS connection, which is a security argument
for this split and not only an operational one.

Digest fidelity was measured under podman on a workstation. It has not
been run under containerd, at cluster scale, or against every registry
the platform uses, and signature verification was not exercised end to
end. Establishing that on one cluster is the first thing to do with this
decision; a failure there would be a decision on its own merits and
would supersede this record.
