{ config, pkgs, ... }:
{
  # NVIDIA GB206 (RTX 5060, Blackwell) for scg-workstation.
  # LTS kernel comes from the host config (boot.kernelPackages =
  # pkgs.linuxPackages); here we pin the latest *stable* driver against
  # that kernel. Blackwell requires the open kernel modules.
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # Expose the active driver to uv-managed Python's dynamic library loading,
  # including interpreters that bypass nix-ld. Preserve caller search paths.
  # Services that bypass shell initialisation need their own environment.
  environment.extraInit = ''
    export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${pkgs.addDriverRunpath.driverLink}/lib"
  '';

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
}
