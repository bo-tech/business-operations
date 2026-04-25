Glossary
========

.. glossary::

   Ansible
      See https://docs.ansible.com/ansible/latest/index.html.

   Cluster
      In the context of this document it refers most of the time to a
      `Kubernetes Cluster <https://kubernetes.io/docs/concepts/architecture/>`_.

      The term is also used in the context of some components and applications
      like `PostgreSQL`_ or `etcd`_.

      Without further context it does refer to the `Kubernetes Cluster`_.

      .. _PostgreSQL: https://www.postgresql.org/
      .. _etcd: https://etcd.io/

   ForwardAuth
      Authentication pattern where a reverse proxy delegates
      authorization decisions to an external service before
      forwarding requests to the backend. See
      :ref:`sec-internal-access`.

   Gateway API
      Kubernetes API for service networking, successor to Ingress.
      Uses GatewayClass, Gateway, and route resources (HTTPRoute,
      TCPRoute, etc.). See https://gateway-api.sigs.k8s.io/.
      Documented in :ref:`sec-external-access` and
      :ref:`sec-internal-access`.

   GatewayClass
      Cluster-scoped Gateway API resource that binds a Gateway to
      a specific controller implementation. See
      `Gateway API concepts <https://gateway-api.sigs.k8s.io/concepts/api-overview/>`_.

   HTTPRoute
      Gateway API resource defining HTTP routing rules from a
      Gateway to backend services. See
      `HTTPRoute documentation <https://gateway-api.sigs.k8s.io/guides/http-routing/>`_.

   Instance
      An instance of the deployment, typically a cluster created based on this
      repository. It represents a specific deployment environment with its own
      configuration, resources, and state.

   CloudNativePG
      Kubernetes operator for PostgreSQL. See https://cloudnative-pg.io/.
      Documented in :ref:`app-postgresql`.

   Helm
      Package manager for Kubernetes. See https://helm.sh/.

   k0s
      See https://k0sproject.io/.

   k0s-nix
      Integrates :term:`k0s` into NixOS.

      See https://github.com/johbo/k0s-nix.

   k0sctl
      See https://docs.k0sproject.io/head/k0sctl-install/.

   Node
      Refers to a `Kubernetes Node
      <https://kubernetes.io/docs/concepts/architecture/nodes/>`_.

   PVC
   PersistentVolumeClaim
      A request for storage in Kubernetes. See
      https://kubernetes.io/docs/concepts/storage/persistent-volumes/.

   Traefik
      Reverse proxy and :term:`Gateway API` controller. See
      https://doc.traefik.io/traefik/. Documented in
      :doc:`core-components/traefik`.

   VolSync
      Replication and backup of persistent volumes. See
      https://volsync.readthedocs.io/. Documented in
      :ref:`sec-backup-restore`.
