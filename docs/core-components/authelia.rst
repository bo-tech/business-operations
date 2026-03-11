.. _app-authelia:

=============
 Authelia IdP
=============

Authelia is used to protect the default ``Ingress`` and provides both
authentication and authorization.

The users are configured via :doc:`lldap`.

.. seealso::

   :ref:`adr-0002`


Secrets handling
================

The command ``authelia crypto`` provides utilities, see
https://www.authelia.com/reference/cli/authelia/authelia_crypto/.

They can be used in a simple container::

   podman run -it --rm authelia/authelia:latest -- sh


Pointers
========

- Project website - https://www.authelia.com/
