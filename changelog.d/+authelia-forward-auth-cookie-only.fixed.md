Authelia's `forward-auth` endpoint authenticates by session cookie
alone. Its default also claims the `Authorization` header and rejects a
request whose scheme it does not recognise before reading the cookie,
which left every application that uses that header for its own scheme
unreachable behind the proxy — Tryton's web client among them, since
the Traefik migration replaced `/api/verify` with an endpoint whose
defaults differ
