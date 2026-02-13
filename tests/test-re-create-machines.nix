let
  rolesPath = ../ansible/roles;
  playbooksPath = ../ansible/playbooks;
  fixturesPath = ./fixtures/re-create-machines;
in
{
  name = "re-create-machines";

  nodes.node1 =
    { lib, ... }:
    {
      imports = [ ../nixos/profiles/k0s-node.nix ];

      networking = {
        useNetworkd = true;
        useDHCP = false;
        firewall.enable = false;
      };

      systemd.network.networks."01-eth1" = {
        name = "eth1";
        networkConfig.Address = "192.168.1.10/24";
      };

      services.k0s = {
        role = "controller+worker";
        controller.isLeader = true;
        spec.api.address = "192.168.1.10";
      };

      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      virtualisation.memorySize = lib.mkForce 4096;
      virtualisation.diskSize = lib.mkForce 8192;
    };

  nodes.worker1 =
    { lib, ... }:
    {
      imports = [ ../nixos/profiles/k0s-node.nix ];

      networking = {
        useNetworkd = true;
        useDHCP = false;
        firewall.enable = false;
      };

      systemd.network.networks."01-eth1" = {
        name = "eth1";
        networkConfig.Address = "192.168.1.11/24";
      };

      services.k0s = {
        role = "worker";
        spec.api.address = "192.168.1.10";
      };

      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      virtualisation.memorySize = lib.mkForce 4096;
      virtualisation.diskSize = lib.mkForce 8192;
    };

  nodes.ansible =
    { pkgs, ... }:
    {
      networking = {
        useNetworkd = true;
        useDHCP = false;
        firewall.enable = false;
      };

      systemd.network.networks."01-eth1" = {
        name = "eth1";
        networkConfig.Address = "192.168.1.20/24";
      };

      environment.systemPackages = with pkgs; [
        ansible
        kubectl
        kubernetes-helm
        openssh
        yq
      ];

      environment.etc."test-workspace".source = fixturesPath;
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

    info = worker1.get_unit_info("k0sworker")
    assert info["ActiveState"] == "inactive", f"Expected inactive, got {info['ActiveState']}"

    ansible.succeed('ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519')
    pubkey = ansible.succeed("cat /root/.ssh/id_ed25519.pub").strip()
    node1.succeed(f"mkdir -p /root/.ssh && echo '{pubkey}' >> /root/.ssh/authorized_keys")
    worker1.succeed(f"mkdir -p /root/.ssh && echo '{pubkey}' >> /root/.ssh/authorized_keys")

    ansible.succeed("cp -rL /etc/test-workspace /workspace")

    ansible.succeed(
        "cd /workspace/ansible && "
        "ANSIBLE_ROLES_PATH=${rolesPath} "
        "ansible-playbook -i inventory.yaml "
        "${playbooksPath}/re-create-machines.yaml "
        "-e skip_nixos_deployment=true "
        "-e skip_rook_ceph=true -v"
    )

    node1.succeed("k0s kubectl wait --for=create nodes/worker1 --timeout=60s")
    node1.succeed("k0s kubectl wait --for=condition=Ready node/worker1 --timeout=120s")

    info = worker1.get_unit_info("k0sworker")
    assert info["ActiveState"] == "active", f"Expected active, got {info['ActiveState']}"

    token_content = worker1.succeed("cat /etc/k0s/k0stoken")
    assert "Token removed after join" in token_content, (
        f"Expected token cleared, got: {token_content}")

    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod -l k8s-app=cilium -n kube-system --timeout=300s"
    )
    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod -l name=cilium-operator -n kube-system --timeout=300s"
    )

    node1.succeed("k0s kubectl wait --for=condition=Ready pod --all -n openebs --timeout=300s")
  '';
}
