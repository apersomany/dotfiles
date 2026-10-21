{
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
