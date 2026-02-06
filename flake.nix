{
  description = "Business Operations - Self-hostable infrastructure platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      nixosModules = {
        nix-flakes = import ./nixos/modules/nix/flakes.nix;
        nix-registry = import ./nixos/modules/nix/registry.nix;
        base-packages = import ./nixos/modules/base-packages.nix;
        container-oci = import ./nixos/modules/container/oci.nix;
        server = import ./nixos/modules/server.nix;
        kubernetes-k0s = import ./nixos/modules/kubernetes/k0s.nix;

        profile-base = import ./nixos/profiles/base.nix;
        profile-oci-container = import ./nixos/profiles/oci-container.nix;
        profile-k0s-node = import ./nixos/profiles/k0s-node.nix;
      };

      ansible = {
        rolesPath = "${self}/ansible/roles";
        playbooksPath = "${self}/ansible/playbooks";
      };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ansiblePackages = [
          pkgs.ansible
          pkgs.sops
          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.openssh
          pkgs.yq
        ];
      in {
        devShells.ansible = pkgs.mkShell {
          packages = ansiblePackages;
          shellHook = ''
            export ANSIBLE_ROLES_PATH="${self}/ansible/roles"
            export BO_PLAYBOOKS="${self}/ansible/playbooks"
            echo "Ansible shell for business-operations"
            echo "Roles: $ANSIBLE_ROLES_PATH"
            echo "Playbooks: $BO_PLAYBOOKS"
          '';
        };
      }
    );
}
