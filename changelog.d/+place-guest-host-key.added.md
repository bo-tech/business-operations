A microVM guest keeps its identity when it is recreated. Deploying one
places the SSH host key from its sops secrets file into the guest's
`/etc` share before first boot, so sops-nix can read the guest's own
secrets. Bare metal already gets this from `nixos-anywhere
--extra-files`; a guest has no installer to do it. Guests without a
secrets file are unaffected.
