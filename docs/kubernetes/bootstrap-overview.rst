============================
 Cluster Bootstrap Overview
============================

The bootstrap is split into multiple stages:

- Bringing up the base infrastructure like the hardware, the operating system
  and a Kubernetes cluster. This provides a functional but empty cluster.

  See the the folder ``/ansible`` regarding a playbook to
  automate this process.

  - Install the base operating system. This is NixOS as configured in
    ``/nixos``. This also deploys and configures the ``k0s``
    distribution.

  - Join the :term:`Nodes <Node>` into the :term:`Cluster`. This is done via
    :term:`Ansible`. See ``/ansible``.

  - Install basic extensions into the cluster. At the moment this is Cilium.
    This is deployed during the cluster creation by Ansible and then updated
    later by Flux.

- ``bootstrap`` is about making FluxCD operational and providing a Git server so
  that FluxCD can start to take over. This group does contain a minimal set of
  applications so that FluxCD is able to work.

  - Bootstrap the FluxCD system according to the instance README.

  - `Gitea` - This is an internal Git server with a small footprint. It hosts a
    clone of this repository, so that FluxCD can access it.

  - `FluxCD` - This is the continuous delivery system in use. It does reconcile
    the cluster state based on the state in this repository.

- ``cluster-base-apps`` groups together the applications which are required so
  that the cluster is fully able to manage itself. The following applications
  are in this group:

  - `Vault` - This is the backend for the secrets handling, it is used to
    provide secrets via `External Secrets`.

  - `External Secrets` - This is used to map secrets from external sources into
    the cluster. Currently this is used to map secrets from the cluster internal
    `Vault` instance.

  - `Gitlab` - This is used as the automation engine to host and build software
    artifacts. It also serves as the source for the GitOps approach.

    - `PostgreSQL` - The bundled database. Intentionally kept, so that there is
      no dependency into a central database service.

    - `MinIO` - The bundled `S3` compatible storage interface. Intentionally
      kept, so that there is no dependency into a central `S3` compatible
      service.

  - :term:`VolSync` - This is used to backup and restore persistent volumes
    from an external `S3` compatible source.

- ``cluster-apps`` are all other services and applications.


The general principle is that a stage is only allowed to depend on the previous
stages, but never on anything from the following stages.

This is also the reason why the Gitlab deployment has its own database and minio
storage.



Secrets bootstrapping
=====================

The applications in ``cluster-base-apps`` cannot yet make usage of `Vault`. This
means that everything needed to restore `Vault` has to be made available via
initial `SOPS` based secrets.


- `flux-system.sops-age` - SOPS Age key. The cluster requires this to decrypt
  the SOPS secrets.

- `secrets.backup-repo` - Secret to encrypt and decrypt the backup repository.

- `secrets.backup-s3` - The S3 access credentials to store and restore the
  backup snapshots.


Pending
-------

- `Vault` needs a solution to automatically unseal itself.



Gitea bootstrapping
===================

`Gitea` is bootstrapped in the following steps:

1. The application itself is deployed by the ``bootstrap`` folder.

2. The repository is created by a `Job` which is also deployed from the
   manifests in the ``bootstrap`` folder.

3. The repository content is pushed in manually.

4. As part of the regular ``cluster-apps`` deployment a `Receiver` for `FluxCD`
   is set up together with the webhook configuration in `Gitea`, so that every
   future push to the repository will trigger the webhook to `FluxCD`.



Improvements
============

The `Gitlab` instance is heavy for code and artifact hosting.
:ref:`app-forgejo` is being integrated as a more lightweight replacement.

Options to further reduce resource usage include external S3 storage and
initially deploying from there, or deploying a lightweight git server plus a
registry for the required artifacts (mainly container images).
