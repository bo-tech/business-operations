{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.business-operations;
in
{
  options.custom.business-operations = {
    enable = lib.mkEnableOption "business-operations platform";

    role = lib.mkOption {
      type = lib.types.enum [
        "single-node"
        "controller"
        "controller+worker"
        "worker"
      ];
    };

    network = {
      address = lib.mkOption {
        type = lib.types.str;
      };

      prefixLength = lib.mkOption {
        type = lib.types.ints.between 0 32;
        default = 24;
      };

      gateway = lib.mkOption {
        type = lib.types.str;
      };

      nameservers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [cfg.network.gateway];
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "eth0";
      };
    };

    cluster.isLeader = lib.mkOption {
      type = lib.types.bool;
      default = cfg.role == "single-node";
    };

    cluster.apiAddress = lib.mkOption {
      type = lib.types.str;
      default = cfg.network.address;
    };

    serialConsole = lib.mkEnableOption "serial console (ttyS0)";

    sshAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    dev.proxy = {
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      caCertificate = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };

      noProxyBase = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "127.0.0.1"
          "localhost"
          ".svc"
          ".cluster.local"
        ];
      };

      noProxy = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    networking.interfaces.${cfg.network.interface}.ipv4.addresses = [
      {
        address = cfg.network.address;
        prefixLength = cfg.network.prefixLength;
      }
    ];
    networking.defaultGateway = cfg.network.gateway;
    networking.nameservers = cfg.network.nameservers;

    boot.kernelParams = lib.mkIf cfg.serialConsole [
      "console=ttyS0,115200"
    ];

    services.k0s = {
      spec.api.address = cfg.cluster.apiAddress;
      role =
        if cfg.role == "single-node"
        then "controller+worker"
        else cfg.role;
    } // lib.optionalAttrs (cfg.role != "worker") {
      controller.isLeader = cfg.cluster.isLeader;
    };

    users.users.root.openssh.authorizedKeys.keys =
      cfg.sshAuthorizedKeys;
    users.users.admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = cfg.sshAuthorizedKeys;
    };
    security.sudo.wheelNeedsPassword = false;

    systemd.services.${config.services.k0s.unitName}.environment =
      lib.mkIf (cfg.dev.proxy.url != null) {
        HTTP_PROXY = cfg.dev.proxy.url;
        HTTPS_PROXY = cfg.dev.proxy.url;
        NO_PROXY = lib.concatStringsSep ","
          (cfg.dev.proxy.noProxyBase ++ cfg.dev.proxy.noProxy);
      };

    security.pki.certificateFiles =
      lib.mkIf (cfg.dev.proxy.caCertificate != null)
        [ cfg.dev.proxy.caCertificate ];
  };
}
