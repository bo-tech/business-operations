=========
 Tooling
=========


OCI Registries
==============

ORAS
----

`ORAS <https://oras.land/>`_

::

   nix profile install nixpkgs#oras
   oras repo tags ghcr.io/fluxcd/flux-manifests


Documentation build
====================

The docs are pinned to the shared ``sphinx-builder`` flake. Use the flake in
``docs/`` for reproducible builds:

- Dev shell with Sphinx and LaTeX: ``cd docs && nix develop``, then
  ``make html`` or ``make latexpdf``.
- One-shot builds: ``cd docs && nix build .#html`` or ``nix build .#pdf``.

The flake lock freezes the builder version; update intentionally via
``nix flake update`` inside ``docs/``.
