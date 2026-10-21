{ pkgs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
    '';
  };

  # Session-wide rather than sway-only, so apps started by systemd user
  # services (the Noctalia launcher) or D-Bus activation also get them. Both
  # fall back to X11 when no Wayland display is available.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "gtk3";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  environment.etc = {
    "sway/config".source = ../../files/sway/config;
    "sway/choose-highest-mode".source = ../../files/sway/choose-highest-mode;
    "sway/reload-noctalia-colors" = {
      source = ../../files/sway/reload-noctalia-colors;
      mode = "0755";
    };
  };

  dotfiles.userFiles.".config/sway/config" = "/etc/sway/config";

  systemd.user = {
    # Noctalia generates ~/.config/sway/noctalia after sway has started (and
    # rewrites it on wallpaper/theme changes) but sway never re-reads it on
    # its own, so watch the file and reload. KillMode=process lets the
    # revived choose-highest-mode daemon survive this oneshot.
    paths."sway-noctalia-colors" = {
      wantedBy = [ "sway-session.target" ];
      pathConfig.PathChanged = "%h/.config/sway/noctalia";
    };

    services."sway-noctalia-colors" = {
      path = [
        pkgs.coreutils
        pkgs.jq
        pkgs.procps
        pkgs.sway
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        KillMode = "process";
        ExecStart = "/etc/sway/reload-noctalia-colors";
      };
    };
  };
}
