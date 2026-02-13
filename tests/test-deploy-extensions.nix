let
  rolesPath = ../ansible/roles;
  playbooksPath = ../ansible/playbooks;
  fixturesPath = ./fixtures/deploy-extensions;
in
{
  name = "deploy-extensions";

  nodes.node1 =
    { config, lib, ... }:
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

  nodes.controller =
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
    node1.succeed(
        "k0s kubectl wait --for=condition=Ready node/node1 --timeout=120s"
    )
    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod --all -A --timeout=120s"
    )

    controller.succeed('ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519')
    pubkey = controller.succeed("cat /root/.ssh/id_ed25519.pub").strip()
    node1.succeed(f"mkdir -p /root/.ssh && echo '{pubkey}' >> /root/.ssh/authorized_keys")
    controller.succeed("ssh -o StrictHostKeyChecking=no root@192.168.1.10 true")

    controller.succeed("cp -rL /etc/test-workspace /workspace")

    controller.succeed(
        "cd /workspace/ansible && "
        "ANSIBLE_ROLES_PATH=${rolesPath} "
        "ansible-playbook -i inventory.yaml "
        "${playbooksPath}/deploy-extensions.yaml -v"
    )

    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod -l k8s-app=cilium -n kube-system --timeout=300s"
    )
    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod -l name=cilium-operator -n kube-system --timeout=300s"
    )
    node1.succeed(
        "k0s kubectl wait --for=condition=Ready pod --all -n openebs --timeout=300s"
    )
  '';
}
