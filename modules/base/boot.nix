{
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  time.timeZone = "Asia/Seoul";
}
