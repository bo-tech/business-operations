===================
 NixOS Installation
===================


Vision
======

Capture the NixOS configuration via Nix Flakes. This way it is easy to keep the
configuration inside of a Git repository which brings the setup already a few
steps closer to a GitOps setup.


Flake overview
==============

The systems are configured in the Nix Flake. The files are structured in the
following way:

- ``./hardware/`` - Hardware configurations in the spirit of the flake
  ``nixos-hardware``.

- ``./machine-classes/`` - Configuration for the logical purpose of the machine.

- ``./hosts/`` - Configuration of specific hosts including the hostname, network
  addresses and similar details.

- ``./modules/`` - Regular NixOS modules.


Installing the systems
======================


Automation via Ansible
----------------------

There is automation around the cluster deployment available in the folder
``ansible/`` which helps to bring up a cluster of machines. It uses some of the
steps described below.


Building the system via nix build
---------------------------------

The system can be built via ``nix build`` and then inspected:

.. code-block:: shell

   nix build .#nixosConfigurations.nixos-test.config.system.build.toplevel

The result is now in the folder ``./result``.


System installation via nixos-anywhere
--------------------------------------

.. warning::

   This will overwrite the current system and set up a fresh NixOS machine. The
   data on the machine will be lost.

The installation of a machine can be done via ``nixos-anywhere``:

.. code-block:: shell

   nix run github:nix-community/nixos-anywhere -- --flake .#nixos-test root@192.0.2.1


On a fresh machine boot into the NixOS installer and then set a password for the
user ``root``. This should be enough to start with ``nixos-anywhere``.


Development and Hacking
========================

The machines have the instance flake registered in the flake registry::

   flake registry list

Flake based configuration in ``/etc/nixos/flake.nix``:

.. code-block:: nix

   {
     inputs.my-ops.url = "git+https://git.server.example/infrastructure/my-ops.git?dir=nixos";

     outputs = { self, my-ops }: {
       inherit (my-ops) nixosConfigurations;
     };
   }

Useful commands::

   nix flake update /etc/nixos

   nixos-rebuild build --flake .#my-host

   nixos-rebuild switch --flake .#my-host

Rebuilding on a remote target::

   nixos-rebuild build --flake .#my-host --target-host root@192.0.2.10

Cloning on the target and rebuilding
-------------------------------------

To build on a NixOS machine without copying a dirty working tree, clone the
repo on the target and rebuild from a branch:

.. code-block:: shell

   ssh root@192.0.2.10
   git clone https://git.server.example/infrastructure/my-ops.git /root/my-ops
   cd /root/my-ops
   git checkout my-branch
   nixos-rebuild switch --flake .#my-host
