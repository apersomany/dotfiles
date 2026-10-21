{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
let
  vesktop = pkgs.vesktop.overrideAttrs (old: {
    postFixup =
      lib.replaceString "--ozone-platform-hint=auto" "--ozone-platform=wayland" old.postFixup
      + ''
        wrapProgram $out/bin/vesktop --set NIXOS_OZONE_WL 1
      '';
  });
  kime = inputs.kime.packages.${pkgs.stdenv.hostPlatform.system}.default;
  persway = inputs.persway.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    src = pkgs.applyPatches {
      inherit (old) src;
      patches = [ ../../patches/persway-stack-main-right.patch ];
    };
  });
in
{
  imports = [
    ./font.nix
    ./kakaotalk.nix
    ./noctalia.nix
    ./sway.nix
  ];

  i18n.inputMethod = {
    enable = true;
    type = "kime";
    package = lib.mkForce kime;
  };

  services = {
    greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;
  };

  dotfiles.userFiles = {
    ".config/alacritty/alacritty.toml" = ../../files/alacritty/alacritty.toml;
    ".config/user-dirs.dirs" = ../../files/user-dirs.dirs;
  };

  xdg.portal.wlr.enable = true;

  # Defaults for types more than one installed app claims; without them GIO
  # picks Chromium (from Pi's browser runtime) or VS Code. Other types resolve
  # to their only handler, and ~/.config/mimeapps.list still takes precedence.
  environment.etc."xdg/mimeapps.list".source = ../../files/mimeapps.list;

  virtualisation.waydroid.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.user == "${username}" &&
        subject.active &&
        subject.local &&
        [
          "org.freedesktop.udisks2.filesystem-mount",
          "org.freedesktop.udisks2.filesystem-mount-system",
          "org.freedesktop.udisks2.filesystem-unmount-others"
        ].indexOf(action.id) >= 0
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface".icon-theme = "Papirus-Dark";
      }
    ];
  };

  environment.systemPackages = [
    pkgs.alacritty
    pkgs.alacritty.terminfo
    pkgs.bibata-cursors
    pkgs.brightnessctl
    pkgs.celluloid
    pkgs.firefox
    pkgs.flameshot
    pkgs.libva-utils
    pkgs.loupe
    pkgs.nautilus
    pkgs.nixd
    pkgs.papirus-icon-theme
    pkgs.remmina
    vesktop
    pkgs.vscode-fhs
    pkgs.wl-clipboard
    persway
  ];
}
