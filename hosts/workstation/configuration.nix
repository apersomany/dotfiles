{ pkgs, ... }:
{
  networking.hostName = "workstation";
  imports = [
    ./hardware-configuration.nix
    ../../modules/waywarp.nix
    ../../modules/base
    ../../modules/desktop
  ];

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-swap-channels.conf" (
      builtins.readFile ../../files/wireplumber/workstation-swap-channels.conf
    ))
  ];

  system.stateVersion = "25.11";
}
