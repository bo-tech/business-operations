ingress-nginx is gone from the platform baseline. Every app the
platform ships answers through the internal Traefik on Gateway API, so
no cluster inherits an Ingress controller any more, and a consumer that
named `base-apps/network/ingress-nginx` replaces it with
`base-apps/network/traefik`. A cluster that still wants ingress-nginx
deploys it itself: the HelmRepository stays under
`flux/repositories/helm`. See ADR-0026.
