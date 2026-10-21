{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  dotfiles.userFiles.".config/noctalia/config.toml" = ../../files/noctalia/config.toml;

  # Noctalia persists settings/state here; without it wallpaper and theme
  # choices are lost and template regeneration breaks. Created by the user
  # manager, so ownership is correct on fresh installs.
  systemd.user.tmpfiles.rules = [ "d %h/.local/state/noctalia 0755 - - -" ];
}
