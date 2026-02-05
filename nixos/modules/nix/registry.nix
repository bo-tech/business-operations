{ pkgs, ... }:
{
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = pkgs.path;
    };

    business-operations.to = {
      type = "github";
      owner = "bo-tech";
      repo = "business-operations";
    };
  };
}
