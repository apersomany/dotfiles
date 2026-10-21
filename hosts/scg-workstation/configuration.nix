{
  networking.hostName = "scg-workstation";
  imports = [
    ./hardware-configuration.nix
    ../../modules/base
    ../../modules/desktop
    ../../modules/drivers/nvidia.nix
    ../../modules/waywarp.nix
  ];

  services.cloudflare-warp.enable = true;

  system.stateVersion = "25.11";
}
