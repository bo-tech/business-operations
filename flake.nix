{
  description = "Business Operations - Self-hostable infrastructure platform";

  outputs = { self }: {
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
  };
}
