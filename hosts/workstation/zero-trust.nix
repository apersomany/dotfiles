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
  # Replaces the official client with a Waywarp copy of its Team registration,
  # imported once with `sudo waywarp import 1`. Routes and DNS follow the
  # registration's policy; restart the service after changing the device
  # profile in the Cloudflare dashboard.
  #
  # Known issue: while this instance runs, the host's /etc/resolv.conf gets
  # replaced with WARP's private one, breaking non-nss resolvers
  # (https://github.com/apersomany/waywarp/issues/2).
  services.waywarp.instances.zero-trust = {
    index = 1;
    access.bridge = { };
  };

  # Readiness is reported once WARP is connected.
  systemd.services.waywarp-zero-trust.serviceConfig = {
    ExecStartPost = "${lib.getExe zeroTrust} up ${toString instance.index}";
    ExecStopPost = "${lib.getExe zeroTrust} down ${toString instance.index}";
  };

  # Gateway is configured on the bridge link at runtime. Without global
  # servers, resolved uses its built-in fallback while the instance is down.
  services.resolved = {
    enable = true;
    settings.Resolve.DNS = [ ];
  };

  # resolved defaults NetworkManager to pushing DHCP resolvers, which would
  # bypass Gateway; keep NetworkManager out of DNS entirely.
  networking.networkmanager.dns = lib.mkForce "none";
}
