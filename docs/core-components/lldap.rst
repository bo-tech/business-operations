.. _app-lldap:

=======
 LLDAP
=======

LLDAP is used as the authentication backend for :doc:`authelia`. It
does provide a Web UI to manage the users in the system.

Only Authelia is intended to use LLDAP as its backend. Other systems should be
integrated only via the SSO mechanisms on their route, or via OIDC.


Secrets handling
================


Admin password
--------------

``lldap`` is configured to update the admin password on every start based on the
configured environment variable. The parameter is
``LLDAP_FORCE_LDAP_USER_PASS_RESET``.


Backup and restore
==================

LLDAP only uses a volume to hold its state. The backup is covered via the
default setup as described in :doc:`/backup-restore/index`.


Pointers
========

- Project repository - https://github.com/lldap/lldap
