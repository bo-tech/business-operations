=========
 MicroVM
=========

The acceptance cluster runs as lightweight VMs on the existing exp
bare-metal nodes using `microvm.nix <https://github.com/astro/microvm.nix>`_.
This reuses spare capacity without dedicated hardware. The same approach
can be used to stand up additional clusters in the future.

VMs are deployed imperatively --- they are not declared in the host's NixOS
configuration. This means host rebuilds do not cause VM downtime.

Overview
========

- ``modules/microvm-bridge.nix`` --- Host module for bridge networking and
  libvirtd ACL configuration.

- ``modules/microvm-guest.nix`` --- Guest module for bootloader, memory
  ballooning, and persistent ``/etc`` via virtiofs.

- ``profiles/`` --- Shared profiles setting common defaults (vCPUs, memory,
  network) for groups of VMs.

- ``hosts/`` --- Per-VM NixOS configurations.


Host Setup
==========

A NixOS host needs preparation before it can run microVMs:

- KVM support
- ``microvm.nixosModules.host``
- Bridge networking

The ``microvm-bridge.nix`` module in ``modules/`` handles the bridge
configuration.


Deploying VMs
=============

Ansible playbooks in ``ansible/playbooks/`` manage the VM
lifecycle. The inventory determines which VMs are deployed to which hosts.

Rebuilding a running VM after configuration changes::

   nix run .#nixosConfigurations.acct-k0s-01.config.microvm.deploy.rebuild


Known Issues
============

deploy-microvms fails on fresh deployment
-----------------------------------------

The ``deploy-microvms.yaml`` playbook runs the ``rebuild`` script which
first installs the VM on the hypervisor host, then tries to SSH into the
VM's IP to activate the config (``switch``). On a fresh deployment the VM
is not running yet, so the SSH connection fails with "Network is
unreachable". The install itself succeeds --- run ``start-microvms.yaml``
afterwards to boot the VMs.
