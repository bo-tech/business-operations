# The zot image is pinned twice: in the node closure, so a Node can
# start the mirror before anything serves it, and in the Deployment the
# mirror runs from. Both live here, so the two can be held together
# rather than watched.
#
# Deliberately not a "test-" file: flake.nix wraps those in
# runNixOSTest, which needs a disabled sandbox and registry access.
{
  pkgs,
  nixpkgs,
  k0s-nix,
  modules,
}:
let
  lib = nixpkgs.lib;

  system = nixpkgs.lib.nixosSystem {
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      k0s-nix.nixosModules.default
      modules.image-bundle
    ];
  };

  pinned = system.config.business-operations.image-bundle.imagesBase.zot;

  expected = "${pinned.imageName}:${pinned.tag}@${pinned.imageDigest}";

  rendered = ../kubernetes/base-apps/registry/zot/app/rendered.yaml;
in
pkgs.runCommand "check-zot-image-pin" { nativeBuildInputs = [ pkgs.yq-go ]; } ''
  actual=$(yq eval-all \
    'select(.kind == "Deployment" and .metadata.name == "zot")
     | .spec.template.spec.containers[] | select(.name == "zot") | .image' \
    ${rendered})

  if [ "$actual" != ${lib.escapeShellArg expected} ]; then
    echo "the zot Deployment runs '$actual'" >&2
    echo "but image-bundle pins '${expected}'" >&2
    exit 1
  fi

  touch $out
''
