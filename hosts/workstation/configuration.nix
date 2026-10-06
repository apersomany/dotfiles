{ pkgs, ... }:
{
  networking.hostName = "workstation";
  imports = [
    ./hardware-configuration.nix
    ./waywarp.nix
    ../../modules/base
    ../../modules/desktop
  ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  services = {
    cloudflare-warp.enable = true;

    pipewire.wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-swap-channels.conf" (
        builtins.readFile ../../files/wireplumber/workstation-swap-channels.conf
      ))
    ];

    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };
  };

  time.timeZone = "Asia/Seoul";
  system.stateVersion = "25.11";
}
