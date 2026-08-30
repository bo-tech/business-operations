.. _sec-quality-goals:

===============
 Quality goals
===============

Reproducible
   A machine and a cluster are rebuilt from source rather than repaired
   into shape. Flake inputs pin what a build resolves to, so a commit
   produces the same system tomorrow.

Restorable
   Bringing a cluster back from backup is a first-class bootstrap mode
   rather than a recovery procedure bolted on afterwards. See
   :ref:`ADR-0012 <adr-0012>`.

Portable
   Nothing binds the setup to one hypervisor, one hoster or one managed
   service. Where a machine runs is chosen per deployment, and
   :ref:`the deployment view <sec-deployment-view>` describes the range.

Approachable
   Someone who did not write it can deploy it. This is what the example
   repository exists for, and what the cheaper
   :ref:`development environments <sec-choosing-an-environment>` are for.
