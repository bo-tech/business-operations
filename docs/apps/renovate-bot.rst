.. _app-renovate-bot:

==============
 Renovate Bot
==============

Renovate is deployed for the Git hosting instance and runs daily; bot identity
and token setup are complete.


Resource sizing
================

Renovate is bursty during dependency lookups but idle otherwise. Start with
``requests: cpu=250m, memory=256Mi`` and ``limits: cpu=1, memory=1Gi`` to keep
runs predictable without starving neighbors. Adjust upward if jobs overlap or
CPU throttles; shrink if the cluster is tight and runs still finish on time.


Access tokens
==============

Use a dedicated Renovate bot user with a personal access token. Add the bot as
a member to every group Renovate should scan (required so APIs list the
projects). Grant ``api``; add ``read_registry`` only if registry access is
needed. Store the token in a SOPS-encrypted Secret and inject it via env in the
CronJob.


Using Renovate
===============

To enable Renovate on a repository, add the ``renovate-bot`` user to the
containing group (preferred) or directly to the project with at least Developer
access; Maintainer may be required for auto-merge flows. Then commit a
``renovate.json`` to the default branch. A minimal starter config is:

.. code-block:: json

   {
     "extends": [
       "local>my-org/renovate/default"
     ]
   }


Pointers
========

- `Renovate Bot Documentation <https://docs.renovatebot.com/>`_
- `Running Renovate in Kubernetes
  <https://docs.renovatebot.com/self-hosted/running-in-kubernetes/>`_


Future improvements
====================

- Add basic monitoring/alerting for Renovate CronJob failures and
  authentication errors.
- Establish a token rotation strategy for Renovate bot users.
- Ensure clear separation so multiple Renovate instances never overlap on the
  same namespaces/projects.
- Add security hardening: minimal permissions for Renovate bot users,
  namespace-scoped tokens, and restricted network access.
