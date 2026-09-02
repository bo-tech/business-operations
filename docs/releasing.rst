=========
Releasing
=========

A release turns what has accumulated since the last one into a version
a consumer can pin.


The release shell
=================

The release tools are not assumed to be installed:

.. code-block:: console

   $ nix develop .#release

Run everything below from that shell.

The first run needs both flake files tracked. Nix will not evaluate an
untracked ``flake.nix``, and ``cog bump`` refuses to start against an
untracked ``flake.lock``:

.. code-block:: console

   $ git add flake.nix
   $ nix flake lock
   $ git add flake.lock


Recording a change
==================

Every change a consumer would notice adds a file to ``changelog.d/``.
The README there says how to name it and what to write. A release
collects the files into a version section and removes them, so two
branches never edit the same lines and a merge cannot conflict over the
changelog.


Making the release
==================

.. code-block:: console

   $ cog bump --patch

This decides the version, writes it into the files that record it,
assembles the changelog, commits the result and tags it.

Pass the increment rather than deriving it while this project is below
``0.1.0``: every kind of change bumps the patch there, which is not
what deriving from commit types would produce. From ``0.1.0`` upward,
``cog bump --auto`` derives it. Moving to ``0.1.0``, and later to
``1.0.0``, is a decision about what the project promises, so it is made
by hand:

.. code-block:: console

   $ cog bump --version 0.1.0

Then push the release commit and its tag:

.. code-block:: console

   $ git push
   $ git push --tags

Build whatever this project publishes from the tag, so that the release
can be built again from the revision the tag names.
