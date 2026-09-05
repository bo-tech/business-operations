# Seeds k0s's images directory from the node closure, so a node can
# come up before anything serves the images it needs (ADR-0037).
#
# Independent of `business-operations.enable`, but not of k0s: the
# directory is k0s's and its path comes from there.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.business-operations.image-bundle;

  imagesDir = "${config.services.k0s.dataDir}/images";

  image = {
    options = {
      imageName = lib.mkOption {
        type = lib.types.str;
        description = "Repository to pull from, without tag or digest.";
      };

      imageDigest = lib.mkOption {
        type = lib.types.str;
        description = "Manifest digest, which is what is pulled.";
      };

      hash = lib.mkOption {
        type = lib.types.str;
        description = "Hash of the archive skopeo writes.";
      };

      tag = lib.mkOption {
        type = lib.types.str;
        description = "Tag recorded in the archive, for reading back.";
      };
    };
  };

  archiveOf =
    entry:
    pkgs.dockerTools.pullImage {
      inherit (entry) imageName imageDigest hash;
      finalImageTag = entry.tag;
    };

  # Stable names, not names derived from the pin: k0s reads this
  # directory without filtering, so an archive a rename left behind
  # would still be imported. The cost is that a changed pin waits for
  # the next k0s start, since nix holds the modification time k0s
  # compares at the epoch.
  linkRule = name: entry: "L+ ${imagesDir}/${name}.tar - - - - ${archiveOf entry}";
in
{
  options.business-operations.image-bundle = {
    enable = lib.mkEnableOption "seeding the k0s images directory from the node closure";

    imagesBase = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule image);
      default = {
        pause = {
          imageName = "quay.io/k0sproject/pause";
          imageDigest = "sha256:1dca17073186db812f380970077f5c82842c810f1bd75800cd926ab50cd34243";
          hash = "sha256-iETVT3wyHvcE7WK6p71ecI4c09NLZgVjEe4Yc0l9KX4=";
          tag = "3.10.2-0";
        };
        zot = {
          imageName = "ghcr.io/project-zot/zot-linux-amd64";
          imageDigest = "sha256:95a837a0afacf5b7edc0c92493f04beee6891989b8d2fd50a00cf65a1e6d4fd5";
          hash = "sha256-v2nllOJNywKAkoIwPQ+RFivlimCsQDA2X7QHyWq0kJg=";
          tag = "v2.1.20";
        };
        cilium = {
          imageName = "quay.io/cilium/cilium";
          imageDigest = "sha256:49d87af187eeeb9e9e3ec2bc6bd372261a0b5cb2d845659463ba7cc10fe9e45f";
          hash = "sha256-onfXgKcbtTLlEpvxNv9hQV8u86YPADC/UsiyLpGAoxk=";
          tag = "v1.18.4";
        };
        cilium-operator = {
          imageName = "quay.io/cilium/operator-generic";
          imageDigest = "sha256:1b22b9ff28affdf574378a70dade4ef835b00b080c2ee2418530809dd62c3012";
          hash = "sha256-L1vXvLT10iCAF3tzd3ANSNEWKzGAjZP61PiHf3uZt0I=";
          tag = "v1.18.4";
        };
      };
      description = ''
        The images a node needs before a mirror can serve them: the
        sandbox image, the mirror itself, and the CNI that would
        otherwise translate the mirror's address. Pinned for amd64.
      '';
    };

    images = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule image);
      default = { };
      description = "Site-specific images, in the same shape.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${imagesDir} 0755 root root -"
    ]
    ++ lib.mapAttrsToList linkRule (cfg.imagesBase // cfg.images);
  };
}
