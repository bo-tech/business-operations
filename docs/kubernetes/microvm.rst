.. _sec-microvm:

=========
 MicroVM
=========

Clusters can run as lightweight VMs on bare-metal nodes using
`microvm.nix <https://github.com/microvm-nix/microvm.nix>`_.
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
   Configure with ``business-operations.microvm-bridge.enable`` and
   ``business-operations.microvm-bridge.physicalNic``.

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
  ``microvm_host``, and sets ``microvm_activate`` to ``switch`` or
  ``restart`` to choose how a deploy activates the new closure.


Host Setup
==========

A NixOS host needs preparation before it can run microVMs:

- KVM support
- ``microvm.nixosModules.host`` (from the microvm.nix flake input)
- ``nixosModules.virtualization`` and ``nixosModules.microvm-bridge``


Deploying VMs
=============

Ansible playbooks manage the VM lifecycle.
All commands assume the ansible dev shell and the inventory file for
the target environment:

.. code-block:: bash

   nix develop ./external/business-operations#ansible
   INVENTORY=./ansible/inventory-microvm.yaml

.. _sec-microvm-deploy:

Deploy VMs to their hypervisor hosts
-------------------------------------

.. code-block:: bash

   ansible-playbook -i $INVENTORY $BO_PLAYBOOKS/deploy-microvms.yaml

On a hypervisor that carries no guest of this name yet, this installs
the NixOS configuration, creates volumes (``/var``, Ceph), and starts
the VM. The inventory must define ``microvm_host`` for each VM.

On one that already carries the guest, a deploy is a switch rather than
a fresh install --- the microvm.nix equivalent of ``nixos-rebuild
switch``. The new closure is installed and then activated, either by
switching into the running guest or by restarting it onto the closure,
depending on ``microvm_activate``. A volume that exists is left alone
and nothing removes ``/var/lib/microvms/<guest>``, so the machine comes
back with the ``var.img`` and ``ceph.img`` it had before, and with them
its etcd and its Flux installation. Bootstrapping such a cluster again
fails at ``kubectl apply --server-side`` with a field manager conflict
against ``kustomize-controller``.

Destroying the guest is therefore what makes the next deploy build a
machine from scratch --- see ``destroy-microvms.yaml`` below. The switch
assumes a guest that is already running; on a first deploy there is
none, which is what `deploy-microvms fails on fresh deployment`_
describes.

Where a VM has a secrets file at ``<flake>/secrets/<vm>.sops.yaml``,
the playbook also places its ``ssh.ssh_host_ed25519_key`` into the
VM's ``/etc`` share before the VM boots. sops-nix decrypts with that
key, so placing it is what lets a VM be destroyed and recreated
without becoming a different machine. A VM without a secrets file
generates a key on first boot as before.

Bootstrap the Kubernetes cluster
---------------------------------

.. code-block:: bash

   ansible-playbook -i $INVENTORY \
     $BO_PLAYBOOKS/bootstrap-existing-machines.yaml

Installs k0s, deploys Cilium, OpenEBS, and Rook-Ceph on the running
nodes.

Kick off FluxCD
----------------

.. code-block:: bash

   ansible-playbook -i $INVENTORY $BO_PLAYBOOKS/bootstrap-cluster.yaml

Deploys the in-cluster Gitea, pushes the repository, applies
cluster settings and secrets, and starts Flux reconciliation.

Other lifecycle playbooks
--------------------------

- ``start-microvms.yaml`` --- Start VM services.
- ``stop-microvms.yaml`` --- Stop VM services.
- ``restart-microvms.yaml`` --- Restart VM services.
- ``destroy-microvms.yaml`` --- Stop the ``microvm@`` unit and remove
  ``/var/lib/microvms/<guest>`` with its volumes, so the next deploy
  builds the machine from scratch.

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
