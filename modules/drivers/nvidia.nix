{
  config,
  lib,
  pkgs,
  ...
}:
let
  driverLibraryPath = "${pkgs.addDriverRunpath.driverLink}/lib";
  driverEnvironment = {
    LD_LIBRARY_PATH = driverLibraryPath;
    TRITON_LIBCUDA_PATH = driverLibraryPath;
  };
  managerDefaults = lib.mapAttrsToList (name: value: "${name}=${value}") driverEnvironment;
in
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
  # Cover dynamic loading even when Python bypasses nix-ld, and Triton's
  # supported driver lookup without /sbin/ldconfig. Preserve caller overrides.
  environment.extraInit = ''
    export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${driverEnvironment.LD_LIBRARY_PATH}"
    export TRITON_LIBCUDA_PATH="''${TRITON_LIBCUDA_PATH:-${driverEnvironment.TRITON_LIBCUDA_PATH}}"
  '';

  # Direct service launches bypass shell initialisation. These manager defaults
  # apply to new processes; explicit per-unit environments still take priority.
  systemd = {
    settings.Manager.DefaultEnvironment = managerDefaults;
    user.settings.Manager.DefaultEnvironment = managerDefaults;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
}
