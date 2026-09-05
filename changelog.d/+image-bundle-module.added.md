A node can carry the images it needs before a registry mirror can
serve them by importing `nixosModules.image-bundle` and enabling
`business-operations.image-bundle`. The module places the archives in
the k0s images directory, from where k0s imports them into containerd
at startup.
