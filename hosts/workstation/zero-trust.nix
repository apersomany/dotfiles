{
  config,
  lib,
  pkgs,
  ...
}:
let
  instance = config.services.waywarp.instances.zero-trust;
  zeroTrust = pkgs.writeShellApplication {
    name = "waywarp-zero-trust";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.iproute2
      pkgs.jq
      config.services.waywarp.package
      config.systemd.package
    ];
    text = builtins.readFile ../../files/waywarp/zero-trust;
  };
in
{
  # Uses a copy of the Team registration, imported once with
  # `sudo waywarp import 1`.
  services.waywarp.instances.zero-trust = {
    index = 1;
    access.bridge = { };
  };

  # Runs once WARP is connected.
  systemd.services.waywarp-zero-trust.serviceConfig = {
    ExecStartPost = "${lib.getExe zeroTrust} up ${toString instance.index}";
    ExecStopPost = "${lib.getExe zeroTrust} down ${toString instance.index}";
  };

  # Gateway DNS is set on the bridge link at runtime.
  services.resolved = {
    enable = true;
    settings.Resolve.DNS = [ ];
  };

  # Otherwise NetworkManager pushes DHCP resolvers that bypass Gateway.
  networking.networkmanager.dns = lib.mkForce "none";
}
