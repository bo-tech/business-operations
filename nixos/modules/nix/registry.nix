{ pkgs, ... }:
{
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = pkgs.path;
    };

    business-operations.to = {
      type = "git";
      url = "https://codeberg.org/business-operations/business-operations";
    };
  };
}
