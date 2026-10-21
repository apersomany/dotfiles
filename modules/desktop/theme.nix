{
  config,
  lib,
  pkgs,
  ...
}:
let
  cursorTheme = "Bibata-Modern-Ice";
  subpixelOrder = config.fonts.fontconfig.subpixel.rgba;
in
{
  environment = {
    systemPackages = [
      pkgs.bibata-cursors
      pkgs.papirus-icon-theme
    ];
    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "gtk3";
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = "24";
    };
  };

  fonts = {
    packages = [
      (pkgs.callPackage ./pkgs/freesentation.nix { })
      pkgs.inter
      pkgs.cascadia-code
      pkgs.nerd-fonts.caskaydia-cove
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "Inter"
          "Freesentation"
        ];
        sansSerif = [
          "Inter"
          "Freesentation"
        ];
        monospace = [
          "Cascadia Code"
        ];
      };
      localConf = builtins.readFile ../../files/fontconfig/korean.conf;
      useEmbeddedBitmaps = true;
      subpixel = {
        lcdfilter = "default";
        rgba = lib.mkDefault "rgb";
      };
    };
  };

  programs.dconf = {
    enable = true;
    profiles.user = {
      enableUserDb = true;
      databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              font-name = "Inter 11";
              font-antialiasing = if subpixelOrder == "none" then "grayscale" else "rgba";
              font-hinting = "slight";
              font-rgba-order = subpixelOrder;
              cursor-theme = cursorTheme;
              icon-theme = "Papirus-Dark";
            };
          };
        }
      ];
    };
  };
}
