{ ... }:
{
  imports = [
    ../modules/nix/flakes.nix
    ../modules/nix/registry.nix
    ../modules/base-packages.nix
    ../modules/container/oci.nix
  ];
}
