.. _sec-certificate-trust:

===================
 Certificate trust
===================

.. note::

   A target picture. Only the public-name half is built today; see
   :ref:`sec-cert-manager`.

Services are reached over TLS and need certificates. The platform issues
them for one case only: a service inside a :term:`Cluster`, reached by a
public name, gets a certificate from a public CA through
``cert-manager``. A
machine outside a cluster, reached by a private name, has no issuer.

The target is one internal CA that speaks ACME and issues certificates
for private names. ``cert-manager`` uses it from inside a cluster, and an
ACME client uses it from a machine outside one. Issuing and renewal then
work the same way in both places, and a deployment has a single trust
anchor instead of one per endpoint.

Public names continue to use a public CA. A name that public
infrastructure already validates gains nothing from an internal
certificate, and clients would have to be given the internal root to
accept one.

The CA runs outside the cluster
===============================

A cluster cannot issue certificates for machines it depends on. If such a
machine's certificate expires while the cluster is down, restoring the
cluster first requires repairing that certificate by hand.

Backup targets, storage holding cluster state, and routers through which
a cluster is reached are all in this position. The CA therefore runs
outside any cluster it issues for.

Private naming is a prerequisite
================================

A certificate binds a name. Without private DNS it can only bind an
address, which changes when a machine moves and requires every client to
trust an address rather than a host.

Private naming and DNS are needed before this picture can be built.

What the platform provides
==========================

The platform provides the CA, the client configuration on both sides, and
the means by which the root certificate reaches clients.

A deployment provides its names, its DNS zone and its own root. A root is
site material, like an address or a credential, and no root is shared
between deployments. See :ref:`sec-architecture-context`.

Before the CA exists
====================

A deployment that needs TLS earlier can issue certificates from an
offline root of its own. Clients see no difference, because a client only
needs a trust anchor, so introducing the CA later changes issuing and not
the clients.
