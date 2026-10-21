{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  dotfiles.userFiles.".config/noctalia/config.toml" = ../../files/noctalia/config.toml;

  # Noctalia doesn't create its state directory, and loses wallpaper and theme
  # choices without it.
  systemd.user.tmpfiles.rules = [ "d %h/.local/state/noctalia 0755 - - -" ];
}
