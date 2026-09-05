{
  pkgs,
  nixpkgs,
  k0s-nix,
  modules,
}:
let
  lib = nixpkgs.lib;

  siteImage = "forge-runner";

  systemWith =
    settings:
    nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        k0s-nix.nixosModules.default
        modules.image-bundle
        { business-operations.image-bundle = settings; }
      ];
    };

  enabled = systemWith {
    enable = true;
    images.${siteImage} = {
      imageName = "forge.internal.example/runner";
      imageDigest = "sha256:${lib.concatStrings (lib.genList (_: "0") 64)}";
      hash = lib.fakeHash;
      tag = "v1";
    };
  };

  disabled = systemWith { enable = false; };

  # The rules name the archives by store path, and a store path in a
  # string carries a dependency on building it. Matching on the strings
  # is the whole point of an evaluation check, so the context goes.
  rulesOf = system: map builtins.unsafeDiscardStringContext system.config.systemd.tmpfiles.rules;

  rules = rulesOf enabled;

  ruleFor = name: lib.findFirst (lib.hasInfix "/var/lib/k0s/images/${name}.tar ") null rules;

  baseImages = [
    "pause"
    "zot"
    "cilium"
    "cilium-operator"
  ];

  missing = name: lib.optional (ruleFor name == null) "no rule places ${name}.tar";

  unlinked =
    name:
    let
      rule = ruleFor name;
    in
    lib.optional (
      rule != null && !lib.hasPrefix "L+ " rule
    ) "${name}.tar is placed by ${lib.head (lib.splitString " " rule)} rather than a symlink";

  failures =
    lib.optional (
      !lib.any (lib.hasPrefix "d /var/lib/k0s/images ") rules
    ) "the images directory is not created"
    ++ lib.concatMap missing (baseImages ++ [ siteImage ])
    ++ lib.concatMap unlinked (baseImages ++ [ siteImage ])
    ++ lib.optional (lib.any (lib.hasInfix "/var/lib/k0s/images") (rulesOf disabled)) "the images directory is touched even though the option is off";
in
pkgs.runCommand "check-image-bundle" { } (
  if failures == [ ] then
    "touch $out"
  else
    ''
      ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f} >&2") failures}
      exit 1
    ''
)
