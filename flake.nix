{
  description = "Business Operations - Self-hostable infrastructure platform";

  outputs = { self }: {
    nixosModules = {
      nix-flakes = import ./nixos/modules/nix/flakes.nix;
      nix-registry = import ./nixos/modules/nix/registry.nix;
      base-packages = import ./nixos/modules/base-packages.nix;
      container-oci = import ./nixos/modules/container/oci.nix;

      profile-base = import ./nixos/profiles/base.nix;
      profile-oci-container = import ./nixos/profiles/oci-container.nix;
    };
  };
}
