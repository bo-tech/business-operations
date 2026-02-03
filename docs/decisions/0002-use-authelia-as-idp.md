---
date: 2023-09-18
---

(adr-0002)=
# 0002 Use Authelia as identity provider

## Context and Problem Statement

There should be one way to log into the various application within the cluster
via single sign on.

Which tool should be used for this?


## Considered options

- Authelia
- Dex


## Decision Outcome

Use Authelia, because it is simpler to set up and get started with. The
federation features of Dex are not (yet) needed and the WebAuthn support for the
second factor is an added value for now.


## Pros and Cons of the Options


### Authelia

- Good, because of a simple setup, no other components are needed.
- Good, because of builtin support for second factor via WebAuthn or One Time Passwords.
- Bad, because there is no federation with external accounts offered.


### Dex

- Good, because of federation support.
- Bad, because it needs an extra component OAuth2 Proxy to plug into the ingress
  controller.
- Bad, because no integrated support for second factors.


## Pointers

- Authelia - <https://www.authelia.com/>
- Dex - <https://dexidp.io/>
- OAuth2 Proxy - <https://oauth2-proxy.github.io/oauth2-proxy/>
