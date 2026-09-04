.. _app-authelia:

=============
 Authelia IdP
=============

Authelia provides both authentication and authorization for the
applications the platform serves. Routes on the internal Traefik delegate
to it through a ForwardAuth middleware; see :ref:`app-traefik`.

Authelia's own route carries no such filter — it is what serves the login.

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
