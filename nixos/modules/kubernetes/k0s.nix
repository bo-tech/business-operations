{ config, pkgs, lib, ... }:
{
  boot.kernel.sysctl = {
    # Required for k0s/kubernetes - prevents "Too many open files" errors
    # https://unix.stackexchange.com/questions/747085
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  environment.systemPackages = with pkgs; [
    dnsutils
    ethtool
    iptables
    config.services.k0s.package
    kmod
    mount
    python3
    tcpdump
    util-linux
  ];

  networking.useDHCP = lib.mkDefault false;

  # Cilium manages its own iptables rules
  networking.firewall.enable = lib.mkDefault false;

  networking.firewall.allowedTCPPorts = [
    6443  # k0s API
  ];

  services.openssh.enable = true;

  services.k0s = {
    enable = true;
    spec = {
      # Using Cilium instead of kube-proxy
      network.kubeProxy.disabled = true;
      network.provider = "custom";
    };
  };
}
