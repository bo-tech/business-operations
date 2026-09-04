# Points containerd at a pull-through registry mirror. Under k0s the
# containerd configuration belongs to k0s: it imports every *.toml in
# /etc/k0s/containerd.d/ and reloads containerd when one appears.
#
# Independent of `business-operations.enable`, so that a node which
# does not run the platform module can still pull through the mirror.
#
# Requires k0s 1.36 or later. The drop-in shape below is containerd 2's
# and 1.36 rejects containerd 1's during pre-flight.
{ config, lib, ... }:

let
  cfg = config.business-operations.registry-mirror;

  # Relative to /etc, so that the drop-in's config_path and the files
  # it points at cannot drift apart.
  certsDir = "k0s/containerd.d/certs.d";

  # `override_path` keeps containerd from appending /v2 to a host URL
  # that already carries one, which is what addressing the upstream as
  # the first path segment requires (ADR-0036).
  hostsToml = registry: server: ''
    server = "${server}"

    [host."${cfg.url}/v2/${registry}"]
      capabilities = ["pull", "resolve"]
      override_path = true
  '';

  hostsFiles = lib.mapAttrs' (
    registry: server:
    lib.nameValuePair "${certsDir}/${registry}/hosts.toml" {
      text = hostsToml registry server;
    }
  ) (cfg.upstreamsBase // cfg.upstreams);
in
{
  options.business-operations.registry-mirror = {
    enable = lib.mkEnableOption "a pull-through registry mirror for image pulls";

    url = lib.mkOption {
      type = lib.types.str;
      description = "Mirror base URL, e.g. http://10.96.0.30:5000";
    };

    upstreamsBase = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        "docker.io" = "https://registry-1.docker.io";
        "quay.io" = "https://quay.io";
        "registry.k8s.io" = "https://registry.k8s.io";
        "ghcr.io" = "https://ghcr.io";
        "docker.gitea.com" = "https://docker.gitea.com";
        "codeberg.org" = "https://codeberg.org";
      };
      description = ''
        Upstreams the platform pulls from on every site, each mapped
        to where containerd resolves what the mirror cannot serve.
      '';
    };

    upstreams = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Site-specific upstreams, in the same shape.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "k0s/containerd.d/registry-mirror.toml".text = ''
        version = 3

        [plugins."io.containerd.cri.v1.images".registry]
        config_path = "/etc/${certsDir}"
      '';
    }
    // hostsFiles;
  };
}
