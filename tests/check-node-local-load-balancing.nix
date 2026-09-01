# Left off, k0s points the konnectivity agent at the node's own API
# address, and only one controller's konnectivity server gets agents.
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

  enabledFor =
    cluster:
    (nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.pkgs = pkgs; }
        k0s-nix.nixosModules.default
        modules.business-operations
        {
          business-operations = {
            enable = true;
            role = "controller+worker";
            network = {
              address = "192.0.2.42";
              gateway = "192.0.2.1";
            };
            inherit cluster;
          };
        }
      ];
    }).config.services.k0s.spec.network.nodeLocalLoadBalancing.enabled;

  failures =
    lib.optional (!enabledFor { multipleControllers = true; })
      "a cluster with several controllers does not get node-local load balancing"
    ++ lib.optional (enabledFor { })
      "node-local load balancing is on for a single controller cluster";
in
pkgs.runCommand "check-node-local-load-balancing" { } (
  if failures == [ ] then
    "touch $out"
  else
    ''
      ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f} >&2") failures}
      exit 1
    ''
)
