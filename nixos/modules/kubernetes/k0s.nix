{ pkgs, ... }:
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
    k0s
    kmod
    tcpdump
  ];

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
