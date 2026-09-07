The external Traefik's egress is restricted to the kube-apiserver and
DNS. A site declares the backends it serves publicly in a policy of its
own; without one, the external gateway reaches nothing. See ADR-0045.
