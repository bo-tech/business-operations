.. _app-gitea:

==========================
 Gitea internal Git server
==========================


Usage
=====

Gitea is used as internal Git server, mainly to support FluxCD's workflow
without requiring a full blown Gitlab instance to be up and running already.


Related decisions
-----------------

.. seealso::

   :ref:`adr-0001`


Known issues
============


Initial push fails
-------------------

Bootstrapping the cluster did fail sometimes with an error message that the
remote did hang up unexpectedly.

This seems to be related to the local Git repository.

Running a garbage collect on the local repository did unlock the situation::

   git gc --aggressive

The cause is not yet fully understood.


Pointers
========

- `Gitea documentation <https://docs.gitea.com/>`_: Internal Git server to host
  the GitOps repositories.
