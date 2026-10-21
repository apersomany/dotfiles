{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5bf40ce6-75c8-4141-82cc-8b955da82372";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
        "ssd"
        "noatime"
        "space_cache=v2"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/5bf40ce6-75c8-4141-82cc-8b955da82372";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "ssd"
        "noatime"
        "space_cache=v2"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/5bf40ce6-75c8-4141-82cc-8b955da82372";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
        "ssd"
        "noatime"
        "space_cache=v2"
      ];
    };

    "/.snapshots" = {
      device = "/dev/disk/by-uuid/5bf40ce6-75c8-4141-82cc-8b955da82372";
      fsType = "btrfs";
      options = [
        "subvol=@snap"
        "compress=zstd"
        "ssd"
        "noatime"
        "space_cache=v2"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7718-4526";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
