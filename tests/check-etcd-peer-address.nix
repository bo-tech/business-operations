# Left unset, k0s-nix's default of 127.0.0.1 applies and three
# controllers cannot form a cluster.
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
  address = "192.0.2.42";

  machine = nixpkgs.lib.nixosSystem {
    modules = [
      { nixpkgs.pkgs = pkgs; }
      k0s-nix.nixosModules.default
      modules.business-operations
      {
        business-operations = {
          enable = true;
          role = "controller+worker";
          network = {
            inherit address;
            gateway = "192.0.2.1";
          };
        };
      }
    ];
  };

  peerAddress = machine.config.services.k0s.spec.storage.etcd.peerAddress;
in
pkgs.runCommand "check-etcd-peer-address" { } (
  if peerAddress == address then
    "touch $out"
  else
    ''
      echo "expected a controller on ${address} to peer over that address," >&2
      echo "but services.k0s.spec.storage.etcd.peerAddress is ${peerAddress}" >&2
      exit 1
    ''
)
