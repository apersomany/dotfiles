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

  # Session-wide so apps started by systemd user services, such as the
  # Noctalia launcher, get them too; the kime module sets its own only for
  # login shells.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
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
