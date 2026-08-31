# The platform module is deliberately absent: the cache-proxy module
# has to configure a node that does not run the platform, which is what
# the six lab hosts in the consuming repository need from it.
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

  url = "http://cache.internal.example:3128";
  site = ".internal.example";
  caCertificate = pkgs.writeText "cache-ca.crt" "";

  machine = nixpkgs.lib.nixosSystem {
    modules = [
      # Not the evaluating system's pkgs: reading the unit's
      # environment forces systemd, which breaks once
      # --all-systems reaches darwin.
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      k0s-nix.nixosModules.default
      modules.cache-proxy
      {
        business-operations.cache-proxy = {
          enable = true;
          inherit url caCertificate;
          noProxy = [ site ];
        };
      }
    ];
  };

  environment = machine.config.systemd.services.k0s.environment;
  noProxy = lib.splitString "," (environment.NO_PROXY or "");

  failures =
    lib.optional (environment.HTTP_PROXY or null != url)
      "HTTP_PROXY is ${toString (environment.HTTP_PROXY or null)}, expected ${url}"
    ++ lib.optional (environment.HTTPS_PROXY or null != url)
      "HTTPS_PROXY is ${toString (environment.HTTPS_PROXY or null)}, expected ${url}"
    ++ lib.optional (!lib.elem "127.0.0.1" noProxy)
      "NO_PROXY lost its base entries: ${environment.NO_PROXY or ""}"
    ++ lib.optional (lib.last noProxy != site)
      "NO_PROXY does not end in the site entry ${site}: ${environment.NO_PROXY or ""}"
    ++ lib.optional (!lib.elem caCertificate machine.config.security.pki.certificateFiles)
      "the proxy CA is not in the system trust store";
in
pkgs.runCommand "check-cache-proxy" { } (
  if failures == [ ] then
    "touch $out"
  else
    ''
      ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f} >&2") failures}
      exit 1
    ''
)
