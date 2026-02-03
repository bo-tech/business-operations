---
date: 2023-09-30
---

(adr-0005)=
# 0005 Adjust the max body size per Ingress resource

## Context and Problem Statement

For some application we need an increased maximum body size, so that bigger
files can be uploaded.

The ingress controller `ingress-nginx` does allow to change the global default
values as well as setting this value per Ingress resource.

Should the default be changed or should this be configured per Ingress object?


## Considered options

- Increase the global default
- Increase the default only per application on its Ingress resources


## Decision Outcome

The configuration will be adjusted on the Ingress resources directly.

The main rationale is that only some applications need the ability to have
bigger files uploaded. This way the need is explicitly stated on the respective
application's configuration. An assumption is that this is also a better
default, so that it is not possible to easily overload applications which are
not prepared to handle huge requests.


## Pointers

- Ingress Nginx Controller - <https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#custom-max-body-size>
