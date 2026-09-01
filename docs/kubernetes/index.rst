============
 Kubernetes
============

The cluster is based on `NixOS`_ provisioned on bare-metal using
`nixos-anywhere`_ for automatic provisioning of the machines. `Ansible`_ is used
to perform additional steps like joining the :term:`Nodes <Node>` into the
:term:`Cluster`.


.. _Ansible: https://docs.ansible.com/ansible/latest/
.. _NixOS: https://nixos.org/
.. _nixos-anywhere: https://nix-community.github.io/nixos-anywhere/


.. toctree::
   :maxdepth: 2

   nixos
   microvm
   multiple-controllers
   caching-proxy
   installation
   ansible
   bootstrap-overview
   crds
   core-components
   external-access
   internal-access
