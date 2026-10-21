{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base
    ../../modules/desktop
    ../../modules/waywarp.nix
    ./zero-trust.nix
  ];

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-swap-channels.conf" (
      builtins.readFile ../../files/wireplumber/workstation-swap-channels.conf
    ))
  ];

  system.stateVersion = "25.11";
}
