Forgejo answers through the internal Traefik. HTTP takes an HTTPRoute
the chart renders, and SSH takes port 22 on the same address, which
Cilium shares between the two Services. ingress-nginx no longer carries
a TCP passthrough.
