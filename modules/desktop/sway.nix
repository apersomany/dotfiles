{ config, pkgs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    # The module's defaults minus foot; Alacritty is the terminal.
    extraPackages = [
      pkgs.brightnessctl
      pkgs.grim
      pkgs.pulseaudio
      pkgs.swayidle
      pkgs.swaylock
      pkgs.wmenu
    ];
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
    '';
  };

  # Session-wide rather than sway-only, so apps started by systemd user
  # services (the Noctalia launcher) or D-Bus activation also get them. Ozone
  # and Qt fall back to X11 when no Wayland display is available. The kime
  # module exports its variables only to login shells; KakaoTalk under
  # XWayland needs XMODIFIERS.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "gtk3";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    GTK_IM_MODULE = config.i18n.inputMethod.type;
    QT_IM_MODULE = config.i18n.inputMethod.type;
    XMODIFIERS = "@im=${config.i18n.inputMethod.type}";
  };

  environment.etc."sway/choose-highest-mode".source = ../../files/sway/choose-highest-mode;

  dotfiles.userFiles.".config/sway/config" = ../../files/sway/config;

  # Sway reads Noctalia's generated colors only at startup or reload.
  systemd.user = {
    paths.sway-noctalia-colors = {
      wantedBy = [ "sway-session.target" ];
      pathConfig.PathChanged = "%h/.config/sway/noctalia";
    };
    services.sway-noctalia-colors.serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.programs.sway.package}/bin/swaymsg reload";
    };
  };
}
