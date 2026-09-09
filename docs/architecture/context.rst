.. _sec-architecture-context:

===================
 Context and scope
===================

Three kinds of consumer use the platform, and each supplies what the
platform deliberately leaves out.

Instance repository
   A private overlay carrying the addresses, secrets and application
   selection of one real deployment. It composes the platform into
   itself and adds what one site needs.

Example
   `demo-ops <https://codeberg.org/business-operations/demo-ops>`_ —
   public, a single-node deployment that can be read and copied.

The platform's own tests
   NixOS VM tests that build machines from the modules with no consumer
   involved.

The platform therefore names no host, no address and no credential.
Everything site-specific arrives from the consumer, which is what lets
one platform commit serve a production cluster and a public example at
the same time.

What the platform provides
==========================

Machine definitions
   NixOS modules for the operating system layer: a machine profile, the
   :term:`k0s-nix` integration, and microVM guest and host support.

A path to a deployable cluster
   Everything between a machine that boots and a :term:`Cluster` that
   accepts workloads — provisioning, cluster bring-up, and the bootstrap
   sequence that leaves a reconciler running. Ansible carries this today
   (:ref:`ADR-0008 <adr-0008>`).

Kubernetes manifests
   Three layers, each met differently by a consumer: a core platform it
   supplies settings for, components it switches on or off, and an
   application catalog it selects from. See
   :ref:`sec-platform-layers`.

What the consumer provides
==========================

Addresses, host names and the network layout. Credentials. Which
components run, which applications are deployed, and how each is
configured. The machines themselves, as NixOS configurations built from
the platform's modules.

It does not provide composition or ordering. Those belong to the
platform, which is what makes the core layer a matter of settings rather
than assembly.
