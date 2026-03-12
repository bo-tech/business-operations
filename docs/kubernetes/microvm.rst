=========
 MicroVM
=========

Clusters can run as lightweight VMs on bare-metal nodes using
`microvm.nix <https://github.com/astro/microvm.nix>`_.
This reuses spare capacity without dedicated hardware and is useful
for acceptance testing or development clusters.

VMs are deployed imperatively --- they are not declared in the host's NixOS
configuration. This means host rebuilds do not cause VM downtime.

The consuming repository provides the ``microvm.nix`` flake input and
imports the appropriate ``nixosModules`` (guest or host).


NixOS Modules
=============

``nixosModules.microvm-guest``
   Guest module (``nixos/modules/microvm/guest.nix``).
   Disables bootloader, enables memory ballooning, and mounts
   persistent ``/etc`` via virtiofs.

``nixosModules.microvm-bridge``
   Host module (``nixos/modules/microvm/bridge.nix``).
   Sets up a bridge (``br0``) so VMs get direct LAN access.
   Configure with ``microvm-bridge.enable`` and
   ``microvm-bridge.physicalNic``.

``nixosModules.virtualization``
   Host module (``nixos/modules/virtualization.nix``).
   Enables libvirtd with KVM support.


Site Configuration
==================

The consuming repository provides:

- **Profiles** --- Shared defaults (vCPUs, memory, volumes, network)
  for groups of VMs.

- **Host configs** --- Per-VM NixOS configurations (IP, MAC, k0s role).

- **Hypervisor configs** --- Physical NIC name, host IP, bridge enable.

- **Ansible inventory** --- Maps VMs to hypervisor hosts via
  ``microvm_host``.


Host Setup
==========

A NixOS host needs preparation before it can run microVMs:

- KVM support
- ``microvm.nixosModules.host`` (from the microvm.nix flake input)
- ``nixosModules.virtualization`` and ``nixosModules.microvm-bridge``


Deploying VMs
=============

Ansible playbooks manage the VM lifecycle:

- ``deploy-microvms.yaml`` --- Install and activate VMs on hypervisors.
- ``start-microvms.yaml`` --- Start VM services.
- ``stop-microvms.yaml`` --- Stop VM services.
- ``restart-microvms.yaml`` --- Restart VM services.
- ``destroy-microvms.yaml`` --- Stop and remove VMs.

The inventory determines which VMs are deployed to which hosts.

Rebuilding a running VM after configuration changes::

   nix run .#nixosConfigurations.<vm-name>.config.microvm.deploy.rebuild


Known Issues
============

deploy-microvms fails on fresh deployment
-----------------------------------------

The ``deploy-microvms.yaml`` playbook installs the VM on the
hypervisor host, then optionally tries to SSH into the VM to activate
the config (``switch`` mode). On a fresh deployment the VM is not
running yet, so the SSH connection fails. The install itself
succeeds --- run ``start-microvms.yaml`` afterwards to boot the VMs.
