# Ansible Roles and Playbooks

Ansible-based automation for k0s cluster deployment. Automates `nixos-anywhere`
calls and the subsequent steps to bootstrap the cluster.


## Vision

The automation should give a fully deployed and restored cluster eventually. The
cluster can be a production cluster or a staging or test environment. Data
restoration is optional, it should allow to restore from a backup according to
the staging access concept.


## Setup

Enter the ansible devShell before running any playbooks:

```sh
nix develop github:bo-tech/business-operations#ansible
```

The devShell provides:

- `ANSIBLE_ROLES_PATH` - points to business-operations/ansible/roles
- `BO_PLAYBOOKS` - points to business-operations/ansible/playbooks


## Usage

### Re-create machines from scratch

Re-create the machines and provide a fresh cluster:

```sh
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/re-create-machines.yaml
```

### Bootstrap cluster

Bootstrap up to FluxCD activation:

```sh
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/bootstrap-cluster.yaml
```

### Rebuild NixOS

Rebuild only the NixOS part (requires the flake to be registered on the
machines, which happens during bootstrap):

```sh
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/rebuild-machines.yaml
```

Rebuild from your local machine (useful when machines cannot access the flake
registry):

```sh
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/rebuild-machines-local.yaml
```


## Development

### Local development of roles

Use the path reference to work with your local business-operations clone:

```sh
nix develop path:/path/to/business-operations#ansible
```

### Faster iteration

To skip the NixOS deployment, run the playbook with:

```sh
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/re-create-machines.yaml \
  -e "skip_nixos_deployment=true"
```

This is useful when iterating on the cluster setup since it provides a faster
feedback loop.


## Inventory Variables

All paths are relative to `inventory_dir`. Helm roles use `cluster-0` as the
reference cluster for HelmRelease files and values.

**Required:**

```yaml
all:
  vars:
    ansible_user: root
    artifacts_dir: "{{ inventory_dir }}/artifacts/cluster-name"
    nixos_flake: ../nixos
    cluster_path: "{{ inventory_dir }}/../../kubernetes/cluster-name"
    nixos_registry_name: "my-flake"  # for remote rebuild
```


## Known Limitations

- A confirmation step should be included to prevent accidents. It should have an
  opt-out for automation scenarios.
- It is not possible to re-create only a single node.
- There is no support for draining the node first.
