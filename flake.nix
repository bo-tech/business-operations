{
  description = "Business Operations - Self-hostable infrastructure platform";

  outputs = { self }: {
    nixosModules = {
      nix-flakes = import ./nixos/modules/nix/flakes.nix;
      nix-registry = import ./nixos/modules/nix/registry.nix;
      base-packages = import ./nixos/modules/base-packages.nix;

      profile-base = import ./nixos/profiles/base.nix;
    };
  };
}
