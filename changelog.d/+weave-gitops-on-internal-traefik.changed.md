weave-gitops answers through the internal Traefik. It kept an nginx
Ingress after the rest of the platform moved, so a cluster deploying it
lost the dashboard when ingress-nginx left. The route carries the
Authelia ForwardAuth filter that ingress-nginx used to apply to every
Ingress through `global-auth-url`, so the gate is unchanged.
