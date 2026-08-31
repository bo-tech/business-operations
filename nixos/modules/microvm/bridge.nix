# Sets up a bridge (br0) for microvm networking.
#
# The host's physical NIC becomes a bridge port (L2 only),
# and the host IP moves to br0. MicroVM TAP interfaces attach to br0
# so VMs get direct LAN access.
#
# Usage: Set `business-operations.microvm-bridge.physicalNic` to the
# host's NIC name.
{ config, lib, ... }:

let
  cfg = config.business-operations.microvm-bridge;
in
{
  options.business-operations.microvm-bridge = {
    enable = lib.mkEnableOption "bridge for microvm networking";
    physicalNic = lib.mkOption {
      type = lib.types.str;
      description = "Physical network interface to bridge (e.g. eno1, enp1s0)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.bridges.br0.interfaces = [ cfg.physicalNic ];
    networking.interfaces.${cfg.physicalNic}.ipv4.addresses = lib.mkForce [];
    # TODO: Workaround for libvirtd overriding microvm.nix's
    virtualisation.libvirtd.allowedBridges = [ "virbr0" "br0" ];
  };
}
