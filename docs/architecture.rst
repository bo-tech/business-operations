.. _sec-architecture:

==============
 Architecture
==============

Business Operations is the platform layer of the setup: NixOS modules
that build a machine, ansible roles that bring a :term:`Cluster` up on
it, and Kubernetes manifests a reconciler applies to it. It holds
nothing that belongs to one site — addresses, secrets and the selection
of applications all arrive from whichever repository consumes it.

.. toctree::
   :maxdepth: 2

   architecture/context
   architecture/quality
   architecture/constraints
   architecture/deployment
   architecture/principles/attached-storage
   architecture/principles/deployment-axes
   architecture/principles/certificate-trust
