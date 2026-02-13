{
  name = "profile-base";
  nodes.machine = {
    imports = [ ../nixos/profiles/base.nix ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("git --version")
    machine.succeed("vim --version")
    machine.succeed("nix --version")
  '';
}
