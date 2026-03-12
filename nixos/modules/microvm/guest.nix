# Common settings for microVM guests.
{ lib, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  microvm.balloon = true;

  microvm.shares = [ {
    proto = "virtiofs";
    tag = "etc";
    source = "share/etc";
    mountPoint = "/etc";
  } ];
}
