{ pkgs, ... }:
{
  networking.hostName = "scg-workstation";
  imports = [
    ./hardware-configuration.nix
    ../../modules/base
    ../../modules/desktop
    ../../modules/drivers/nvidia.nix
    ../../modules/waywarp.nix
  ];

  # LTS kernel (linuxPackages). nvidia.nix pins stable driver against it.
  boot.kernelPackages = pkgs.linuxPackages;

  # Temporary first-boot password for aperso. Change with `passwd` after
  # install, then remove this line and rebuild.
  users.users.aperso.initialPassword = "nixos";

  system.stateVersion = "25.11";
}
