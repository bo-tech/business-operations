The internal Traefik base serves HTTPS on its own. Its `websecure`
listener names `wildcard-tls-secret`, so a consumer that includes
`base-apps/network/traefik` gets a Traefik that serves rather than one
it has to finish in a site overlay. The consumer supplies the
certificate and includes `shared/gateway-tls-referencegrant`, which
admits Gateways in `network` to Secrets in `cert-manager`. The
git-pages Gateway, its second address and its entrypoint moved into
`base-apps/network/traefik/components/git-pages`, so only a cluster
that selects the component needs `${cluster_git_pages_ip}`. See
ADR-0047.
