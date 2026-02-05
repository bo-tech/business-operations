{ lib, ... }:
{
  system.installer.channel.enable = false;

  boot.isContainer = true;
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.modprobeConfig.enable = false;

  networking.useDHCP = false;
  networking.resolvconf.enable = false;

  services.journald.console = "/dev/console";

  systemd.services.audit.enable = false;
  systemd.services.auditd.enable = false;
  systemd.services.nscd.enable = false;
  systemd.services.nscd.preStart = ''
    mkdir -p /var/run/nscd
  '';
}
