{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "consoleblank=600"
  ];

  powerManagement.cpuFreqGovernor = "schedutil";
}
