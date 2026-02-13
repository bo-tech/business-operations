{
  name = "k0s-profile";
  nodes.node1 =
    { config, ... }:
    {
      imports = [ ../nixos/profiles/k0s-node.nix ];
      services.k0s = {
        spec.api.address = config.networking.primaryIPAddress;
        controller.isLeader = true;
        role = "controller+worker";
      };
    };
  testScript = ''
    start_all()
    node1.wait_for_unit("k0scontroller")
    node1.wait_for_file("/run/k0s/status.sock")
    node1.succeed("k0s status")
  '';
}
