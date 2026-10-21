{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  # Apps it launches inherit its environment, and Chromium and Electron choose
  # Wayland only when the session type says so.
  systemd.user.services.noctalia.environment.XDG_SESSION_TYPE = "wayland";

  dotfiles.userFiles.".config/noctalia/config.toml" = ../../files/noctalia/config.toml;

  # Noctalia doesn't create its state directory, and loses wallpaper and theme
  # choices without it.
  systemd.user.tmpfiles.rules = [ "d %h/.local/state/noctalia 0755 - - -" ];
}
