A node can pull container images through a registry mirror by importing
`nixosModules.registry-mirror` and setting
`business-operations.registry-mirror`. The module writes the k0s
containerd drop-in and a `hosts.toml` per upstream. Requires k0s 1.36.
