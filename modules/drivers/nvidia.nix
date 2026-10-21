{
  config,
  pkgs,
  ...
}:
let
  driverLibraryPath = "${pkgs.addDriverRunpath.driverLink}/lib";
  managerDefaults = [
    "LD_LIBRARY_PATH=${driverLibraryPath}"
    "TRITON_LIBCUDA_PATH=${driverLibraryPath}"
  ];
in
{
  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    nvidia = {
      # Blackwell requires the open kernel modules.
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # CUDA libraries for Python that bypasses nix-ld, and for Triton, which
  # otherwise looks the driver up with /sbin/ldconfig. Shells keep caller
  # overrides; the manager defaults cover services started outside a shell.
  environment.extraInit = ''
    export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${driverLibraryPath}"
    export TRITON_LIBCUDA_PATH="''${TRITON_LIBCUDA_PATH:-${driverLibraryPath}}"
  '';
  systemd = {
    settings.Manager.DefaultEnvironment = managerDefaults;
    user.settings.Manager.DefaultEnvironment = managerDefaults;
  };
}
