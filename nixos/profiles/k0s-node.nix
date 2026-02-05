{ ... }:
{
  imports = [
    ../modules/nix/flakes.nix
    ../modules/nix/registry.nix
    ../modules/base-packages.nix
    ../modules/server.nix
    ../modules/kubernetes/k0s.nix
  ];
}
