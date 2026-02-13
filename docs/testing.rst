=======
Testing
=======

Tests use the NixOS VM test framework (``testers.runNixOSTest``). Test files
in ``tests/`` are auto-discovered and exposed as ``checks`` in the flake.

.. seealso::

   Relevant decisions:

   - :ref:`adr-0019`
   - :ref:`adr-0020`


Running the tests
=================

Run a specific test:

.. code-block:: bash

   nix build .#checks.aarch64-darwin.profile-base -L


Disable the sandbox for tests which need network access:

.. code-block:: bash

   nix build .#checks.aarch64-darwin.k0s-profile -L --option sandbox false


Interactive debugging with a Python REPL (runs outside the sandbox):

.. code-block:: bash

   nix build .#checks.aarch64-darwin.k0s-profile.driver
   ./result/bin/nixos-test-driver --interactive


Test network layout
===================

Multi-node tests share the ``192.168.1.0/24`` subnet on ``eth1``. Addresses
are grouped by role:

.. list-table::
   :header-rows: 1
   :widths: 20 50

   * - Range
     - Purpose
   * - ``.1`` – ``.9``
     - Infrastructure (router, DNS, DHCP, ...)
   * - ``.10`` – ``.19``
     - Kubernetes nodes (controllers, workers)
   * - ``.20`` – ``.29``
     - Utility nodes (ansible control node, ...)


More information
================

- `NixOS manual: Integration testing
  <https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests>`_

- `nix.dev: Integration testing using virtual machines
  <https://nix.dev/tutorials/nixos/integration-testing-using-virtual-machines>`_
