{ config, pkgs, ... }:
let
  kakaotalk = pkgs.writeShellApplication {
    name = "kakaotalk";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.util-linux
      pkgs.wineWow64Packages.stableFull
    ];
    runtimeEnv = {
      LOCALE_ARCHIVE = "${config.i18n.glibcLocales}/lib/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${config.i18n.glibcLocales}/lib/locale/locale-archive";
      KAKAOTALK_FONTS = "${pkgs.callPackage ./pkgs/freesentation.nix { }}/share/fonts/truetype";
      KAKAOTALK_FONT_REGISTRY = ../../files/kakaotalk/fonts.reg;
    };
    text = builtins.readFile ../../files/kakaotalk/launch.sh;
  };
in
{
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
  ];

  environment.systemPackages = [
    kakaotalk
    (pkgs.makeDesktopItem {
      name = "kakaotalk";
      desktopName = "KakaoTalk";
      comment = "KakaoTalk for Windows via Wine";
      exec = "${kakaotalk}/bin/kakaotalk";
      icon = "system-users";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      startupWMClass = "kakaotalk.exe";
    })
  ];
}
