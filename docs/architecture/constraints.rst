.. _sec-architecture-constraints:

=============
 Constraints
=============

The layers stay separable
   The operating system is one layer, the Kubernetes distribution
   another, and the workloads inside the cluster a third. NixOS and
   :term:`k0s` are the current choices, not fixed points. This does not
   mean the setup runs on any operating system or any distribution — it
   means either choice can be revisited without the layers above it
   having to follow. Keeping that true is what forbids a workload from
   depending on how the node beneath it was built.

The cluster carries its own foundations
   Storage and git hosting run inside the cluster rather than beside it.
   A deployment does not stand up a Ceph cluster and then build
   Kubernetes on top of it — the :term:`Cluster` comes up first, and its
   foundations arrive as workloads on it. That ordering is what the
   manifest layers express: ``bootstrap`` brings up what the reconciler
   itself needs, ``base-apps`` the components every cluster carries —
   storage, networking, secrets, backup — and ``apps`` the workloads a
   consumer selects.

The state lives in git
   Git holds the cluster's desired state, and a running cluster is
   changed by changing what git holds rather than by acting on the
   cluster directly. How that state reaches the cluster is not fixed:
   Flux pulls it today, and a push model would satisfy the same
   constraint.

Bootstrap without an external dependency
   Bringing a cluster up does not depend on reaching a service outside
   it. Pulling requires a git remote, so the platform bootstraps a Gitea
   instance inside the cluster to be that remote (:ref:`ADR-0001
   <adr-0001>`); pushing would require neither.

   Some external dependencies are deliberate. A restore reads the backup
   from off-site storage, which is the whole point of keeping it there.
   The constraint rules out the dependencies nobody chose, not the ones a
   deployment took on knowingly.

Nothing site-specific in the platform
   No host name, address or credential is written here. A value only one
   deployment could want belongs to the consumer, and a platform default
   exists so the consumer can override it rather than restate it.
