.. _app-forgejo:

========
 Forgejo
========

Forgejo is being integrated as the code hosting platform, intended to
replace GitLab for repository hosting and CI — it is more lightweight.


Deployment defaults
===================

:Namespace: ``code``
:Host: ``code.<cluster_domain>``
:SSH: ``code.<cluster_domain>:22``
:Manifests: ``kubernetes/apps/code/forgejo/``


Routing
=======

HTTP is served by the internal Traefik. The chart renders the
``HTTPRoute`` from the ``httpRoute`` values (:ref:`adr-0043`), and no
ForwardAuth filter is attached to it: ``code.<cluster_domain>`` is a
bypass in the Authelia rules, and git over HTTPS, the API, the container
registry and the Actions runners must not meet a login redirect.

``DOMAIN`` and ``ROOT_URL`` are set explicitly. With no ingress values
to derive them from, the chart would fall back to its own default host.

SSH answers on the same address, which Cilium shares between Traefik and
Forgejo's own SSH Service (:ref:`adr-0044`). Forgejo announces one
hostname for both, so they cannot be separated.


Access
======

The Helm chart generates a random admin password on first install if no
``forgejo-admin`` Secret exists. To use a specific password, create the Secret
before deploying.


Database
========

Forgejo uses a dedicated :term:`CloudNativePG` cluster.
See :ref:`app-postgresql` for the operator setup and backup approach.


Storage
=======

Repository data lives on a dedicated :term:`PVC` backed up via :term:`VolSync`.
See :ref:`sec-backup-restore` for the general approach.


Configuration
=============

Forgejo is installed via the official :term:`Helm` chart. The site
overlay should provide instance-specific values such as admin
credentials and the webhook allow list.

Defaults
--------

- **Registration** is disabled. An administrator creates user accounts
  through the web UI or CLI.
- **Default repo units**: code, releases, pulls, packages, actions —
  issues and wiki are off by default for new repositories.


Pointers
========

- `Forgejo Documentation <https://forgejo.org/docs/latest/>`_
- :doc:`/decisions/0044-share-the-internal-traefik-address-for-ssh`
