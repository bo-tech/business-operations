=========================
 Core components overview
=========================

- :doc:`/core-components/authelia`: Authentication and authorization, provides
  SSO and OIDC

  - :doc:`/core-components/lldap`: User directory, only used by Authelia

- `Cilium <https://github.com/cilium/cilium>`_: Internal Kubernetes networking
  plugin.

- `cert-manager <https://cert-manager.io/docs/>`_: Creates SSL certificates for
  services in the Kubernetes cluster.

- `external-secrets <https://github.com/external-secrets/external-secrets/>`_:
  Managed Kubernetes secrets.

- :doc:`/core-components/gitea`: Cluster internal Git server.

- `ingress-nginx <https://github.com/kubernetes/ingress-nginx/>`_: Legacy
  ingress controller, being replaced by :doc:`/core-components/traefik`.

- :doc:`/core-components/traefik`: :term:`Gateway API` controller for
  external and internal traffic.

- :doc:`/core-components/openebs` is used to provision local volumes via the
  storage class ``openebs-hostpath``.

- :doc:`/core-components/rook` is used to provide the default storage.

- `SOPS <https://fluxcd.io/flux/guides/mozilla-sops/>`_: Managed secrets for
  Kubernetes, Ansible and Terraform which are committed to Git.

- `Vault <https://developer.hashicorp.com/vault/docs>`_: Cluster internal
  secrets store.

- `VolSync <https://volsync.readthedocs.io/en/stable/>`_: Regular backups via
  Restic into S3 storage. During bootstrap the volumes are restored from these
  backups.
