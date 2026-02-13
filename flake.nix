{
  description = "Business Operations - Self-hostable infrastructure platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    k0s-nix = {
      url = "github:johbo/k0s-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, k0s-nix }:
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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ k0s-nix.overlays.default ];
        };
        lib = nixpkgs.lib;
        ansiblePackages = [
          pkgs.ansible
          pkgs.sops
          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.openssh
          pkgs.yq
        ];
        testNames = map (name: lib.strings.removeSuffix ".nix" name)
          (builtins.attrNames (builtins.readDir ./tests));
      in {
        checks = lib.genAttrs testNames (test:
          pkgs.testers.runNixOSTest {
            imports = [ ./tests/${test}.nix ];
            defaults = {
              imports = [ k0s-nix.nixosModules.default ];

              # Useful during interactive debugging
              services.getty.autologinUser = "root";

              # QEMU's slirp interface, needed for network access
              networking.interfaces.eth0.useDHCP = true;

              virtualisation.diskSize = 4096;

              # TODO: Cilium is not yet installed, use defaults interim
              services.k0s.spec = {
                network.kubeProxy.disabled = lib.mkForce false;
                network.provider = lib.mkForce "kuberouter";
              };
            };
          }
        );

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
