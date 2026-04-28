.. _app-git-pages:

.. index:: git-pages, pages

=========
git-pages
=========

`git-pages` is a static site server for Git forges — a self-hosted
alternative to GitHub Pages or Netlify.


Deployment defaults
===================

:Namespace: ``code``
:Host: ``*.pages.<cluster_domain>``
:Manifests: ``kubernetes/apps/code/git-pages/``
:Upstream: `codeberg.org/git-pages/git-pages
  <https://codeberg.org/git-pages/git-pages>`_


Publishing content
==================

Two paths are available:

**Webhook clone** — configure a Forgejo webhook on the repository.
On push to the ``pages`` branch, `git-pages` clones and serves the
content. No CI needed.

**Archive upload** — a CI pipeline builds the site and uploads a
tar/zip archive with a ``Forge-Authorization`` header. Use this for
sites that need a build step (Sphinx, Hugo, etc.).

Both produce the same result. A site can start on the webhook path
and move to CI-built without server-side changes.


URL scheme
==========

- ``https://<user>.pages.<cluster_domain>/`` serves the index site
  from ``<user>/pages``.
- ``https://<user>.pages.<cluster_domain>/<project>/`` serves a
  project site from ``<user>/<project>``.

Organizations work the same way as users.


Custom domains
==============

Domains outside the wildcard (e.g. a personal blog) use DNS-based
authorization. Add a TXT record at ``_git-pages-challenge.<domain>``
containing ``SHA256("<domain> <token>")``, then pass the token via
the ``Authorization: Pages <token>`` header when publishing. An A or
CNAME record pointing to the cluster ingress serves the site.


Access control
==============

The deployment exposes two Services (see :ref:`adr-0028`):

``git-pages``
   Full access on port 3000. Used by internal routes, webhooks,
   and CI archive uploads.

``git-pages-read-only``
   Read-only proxy (nginx sidecar) on port 8080. Returns 405 for
   anything other than GET/HEAD/OPTIONS. External HTTPRoutes for
   custom domains should target this Service.


Storage
=======

Site data is stored on the filesystem via a dedicated :term:`PVC`
backed up via :term:`VolSync`. See :ref:`sec-backup-restore` for the
general approach.


Pointers
========

- `git-pages README <https://codeberg.org/git-pages/git-pages>`_
- `git-pages CLI <https://codeberg.org/git-pages/git-pages-cli>`_
- `Forgejo Action <https://codeberg.org/git-pages/action>`_
