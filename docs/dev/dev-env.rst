========================
 Development Environment
========================

This section does describe how to set up an environment for working on this
setup.

At the moment it is assumed that different flavors are useful depending on the
specific need:

- A "local environment" for fast iteration. This is basically a functional
  cluster and a deployment of Flux into it so that one can add components as
  needed instead of deploying the whole setup.

  Some features like SSL, announcing IP addresses on the local network, backup
  are optional in this case.

- A "full environment" would be a temporary full deployment of the setup. This
  would be needed to verify that the whole bootstrap procedure work as expected.

- An "acceptance environment" is technically the same as a "full environment",
  in contrast it would be bootstrapped based on a production snapshot.

The best approach still has to be found and evolve over time.


Local development
=================

A fast feedback loop is required when working on a change. A restore from a
backup is optional, instead a bootstrap from scratch can be more useful.


Basis: a cluster
-----------------

Suggested: Use ``minikube``:

.. code-block:: shell

   # Optional
   export DOCKER_HOST=ssh://user@192.0.2.1

   # Start it
   minikube start --driver=docker

The basis must be an existing cluster. This can be a virtual machine with a
single node cluster, a ``kind`` based cluster or a virtual cluster in a given
host cluster.

Not all features are possible in every variant:

- L2 IP Announcements via Cilium may be limited or not possible.

- Ceph based storage.


Opinionated Flux deployment
----------------------------

Quickstart::

   # Be inside of the directory ./kubernetes/dev-env/
   task c:bootstrap

An opinionated Flux deployment into the cluster is required. The deployment
should match the production cluster overlay, so that it provides an environment
with sufficient similarity to production.

A ``git push`` into the cluster should be possible based on the integrated Gitea
instance.


Template for Flux based development
-------------------------------------

A template could also be a repository in which one would create a branch for the
specific environment. Then it would also provide an easy way to share
environments based on publishing the branch or creating a fork.

Currently using ``./kubernetes/dev-env`` inside of the instance repository.


Plain Helm, Helmfile and kubectl based development
---------------------------------------------------

Working with plain Helm, Helmfile and kubectl or any other Kubernetes tooling is
an alternative for fast local iteration.
