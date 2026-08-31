# Routes the k0s unit's fetches through a caching proxy. That unit
# alone: nix runs under its own and goes direct.
#
# Independent of `business-operations.enable`, so that a node which
# does not run the platform module can still use the cache.
{ config, lib, ... }:

let
  cfg = config.business-operations.cache-proxy;
in
{
  options.business-operations.cache-proxy = {
    enable = lib.mkEnableOption "caching proxy for the k0s unit";

    url = lib.mkOption {
      type = lib.types.str;
      description = "Proxy URL, e.g. http://cache.internal.example:3128";
    };

    caCertificate = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        CA certificate of a proxy that terminates TLS. Null where the
        proxy does not inspect it.
      '';
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
      description = "Destinations that bypass the proxy on every site.";
    };

    noProxy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Site-specific destinations that bypass the proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.k0s.environment = {
      HTTP_PROXY = cfg.url;
      HTTPS_PROXY = cfg.url;
      NO_PROXY = lib.concatStringsSep ","
        (cfg.noProxyBase ++ cfg.noProxy);
    };

    security.pki.certificateFiles =
      lib.mkIf (cfg.caCertificate != null) [ cfg.caCertificate ];
  };
}
