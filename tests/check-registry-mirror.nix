# The platform module is deliberately absent: the registry-mirror
# module has to configure a node that does not run the platform, the
# same population cache-proxy serves.
#
# Deliberately not a "test-" file: flake.nix wraps those in
# runNixOSTest, which needs a disabled sandbox and registry access.
{
  pkgs,
  nixpkgs,
  k0s-nix,
  modules,
}:
let
  lib = nixpkgs.lib;

  url = "http://10.96.0.30:5000";
  siteUpstream = "forge.internal.example";

  machine = nixpkgs.lib.nixosSystem {
    modules = [
      # Not the evaluating system's pkgs: a NixOS system evaluates for
      # Linux whatever system the check itself is built for.
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      k0s-nix.nixosModules.default
      modules.registry-mirror
      {
        business-operations.registry-mirror = {
          enable = true;
          inherit url;
          upstreams = {
            ${siteUpstream} = "https://${siteUpstream}";
          };
        };
      }
    ];
  };

  etc = machine.config.environment.etc;

  textOf = path: (etc."k0s/containerd.d/${path}" or { text = null; }).text;

  dropIn = textOf "registry-mirror.toml";
  hostsFor = registry: textOf "certs.d/${registry}/hosts.toml";

  baseUpstreams = [
    "docker.io"
    "quay.io"
    "registry.k8s.io"
    "ghcr.io"
    "docker.gitea.com"
    "codeberg.org"
  ];

  missing = registry: lib.optional (hostsFor registry == null) "no hosts.toml for ${registry}";

  dockerHosts = hostsFor "docker.io";

  contains = haystack: needle: haystack != null && lib.hasInfix needle haystack;

  failures =
    lib.optional (
      !contains dropIn "version = 3"
    ) "the drop-in does not carry containerd 2's version = 3"
    ++ lib.optional (
      !contains dropIn ''config_path = "/etc/k0s/containerd.d/certs.d"''
    ) "the drop-in does not point containerd at the certs.d directory"
    ++ lib.concatMap missing (baseUpstreams ++ [ siteUpstream ])
    ++ lib.optional (
      !contains dockerHosts ''server = "https://registry-1.docker.io"''
    ) "docker.io falls back to something other than registry-1.docker.io"
    ++ lib.optional (
      !contains dockerHosts ''[host."${url}/v2/docker.io"]''
    ) "docker.io is not addressed as the mirror's first path segment"
    ++ lib.optional (
      !contains dockerHosts "override_path = true"
    ) "docker.io's host entry lacks override_path, so containerd appends /v2";
in
pkgs.runCommand "check-registry-mirror" { } (
  if failures == [ ] then
    "touch $out"
  else
    ''
      ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f} >&2") failures}
      exit 1
    ''
)
