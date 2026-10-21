{ pkgs, ... }:
let
  cursorTheme = "Bibata-Modern-Ice";
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
        rgba = "rgb";
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
              font-antialiasing = "rgba";
              font-hinting = "slight";
              font-rgba-order = "rgb";
              cursor-theme = cursorTheme;
              icon-theme = "Papirus-Dark";
            };
          };
        }
      ];
    };
  };
}
