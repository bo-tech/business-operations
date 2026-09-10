The CRD Kustomizations no longer prune. `external-secrets`,
`kube-prometheus-stack` and `volsync` now match `gateway-api` and
`traefik`, which already carried `prune: false`.

Pruning a CRD Kustomization deletes the CustomResourceDefinitions in
it, and Kubernetes deletes every custom resource of that kind with
them. For volsync that is the ReplicationSources describing the
backups: the snapshots in S3 survive, the configuration that writes
and restores them does not. A CRD set is removed from a cluster
deliberately, not as a side effect of an edit to a list.
