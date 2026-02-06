---
date: 2026-02-06
---

(adr-0018)=
# 0018 Exposing ansible via Nix devShell

## Context and Problem Statement

business-operations contains reusable ansible roles and playbooks for k0s
cluster management. Consuming repositories (b-ops, demo-ops) need to use these
roles with their site-specific inventories.

How should the ansible environment be exposed for consumption?

## Considered Options

1. **Git submodule** - Include business-operations as submodule, reference
   roles via relative path
2. **Ansible Galaxy** - Publish roles to Galaxy, install via requirements.yml
3. **Nix devShell** - Expose devShell with ANSIBLE_ROLES_PATH set, similar to
   NixOS module consumption pattern

## Decision Outcome

Use option 3: Nix devShell with environment variables.

The flake exposes `devShells.ansible` which:

- Provides required tools (ansible, sops, kubectl, helm, yq)
- Sets `ANSIBLE_ROLES_PATH` to business-operations/ansible/roles
- Sets `BO_PLAYBOOKS` to business-operations/ansible/playbooks

**Usage from consuming repository:**

```bash
cd b-ops/infrastructure/ansible
nix develop github:bo-tech/business-operations#ansible
ansible-playbook -i ./inventory.yaml $BO_PLAYBOOKS/re-create-machines.yaml
```

**Local development with path reference:**

```bash
nix develop path:../../../business-operations#ansible
```

## Consequences

The long-term role of ansible in this project is not fully clear yet. As the
platform matures, more functionality may shift to NixOS modules or other
tooling. Given this uncertainty, investing in Ansible Galaxy publishing
infrastructure is not justified at this point.

The devShell approach is lightweight and sufficient for current needs. If
ansible usage grows and external consumers emerge, Galaxy publishing can be
reconsidered.
