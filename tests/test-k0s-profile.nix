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
    serial_stdout_off()

    node1.wait_for_unit("k0scontroller")
    node1.wait_for_file("/run/k0s/status.sock")
    print(node1.succeed("k0s status"))
    node1.succeed("k0s kubectl wait --for=create nodes/node1 --timeout=60s")
    node1.succeed("k0s kubectl wait --for=condition=Ready node/node1 --timeout=120s")
    node1.succeed("k0s kubectl wait --for=condition=Ready pod --all -A --timeout=120s")
  '';
}
