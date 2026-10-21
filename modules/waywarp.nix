{
  config,
  pkgs,
  inputs,
  ...
}:
let
  braveEnter = pkgs.writeShellApplication {
    name = "brave-waywarp-enter";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.iproute2
      pkgs.procps
      pkgs.util-linux
    ];
    text = builtins.readFile ../files/waywarp/brave-enter;
  };
  braveWaywarp = pkgs.writeShellApplication {
    name = "brave-waywarp";
    text = ''
      if (( EUID == 0 )); then
        echo "Run brave-waywarp as your regular user, not as root." >&2
        exit 1
      fi
      export HOME USER LOGNAME
      exec /run/wrappers/bin/sudo \
        --preserve-env=HOME,USER,LOGNAME,DISPLAY,WAYLAND_DISPLAY,XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS,XAUTHORITY,XDG_CONFIG_HOME,XDG_CACHE_HOME,XDG_DATA_HOME,XDG_STATE_HOME,NIXOS_OZONE_WL \
        -- ${braveEnter}/bin/brave-waywarp-enter ${pkgs.brave}/bin/brave --ozone-platform=wayland "$@"
    '';
  };
in
{
  imports = [ inputs.waywarp.nixosModules.default ];

  sops.secrets.waywarp-mudfish = {
    sopsFile = ../secrets/waywarp-mudfish.env;
    format = "dotenv";
    # Emit the whole file in systemd environment-file syntax.
    key = "";
    restartUnits = [ "waywarp-osaka.service" ];
  };

  services.waywarp.instances.osaka = {
    index = 0;
    access.bridge = { };
    location = "geo4=JP/Osaka+edge=KIX";
    via = [ "mudfish:city=osaka+provider=azure" ];
    environmentFile = config.sops.secrets.waywarp-mudfish.path;
  };

  # Skipped rather than failed until the host can decrypt the secret.
  systemd.services.waywarp-osaka.unitConfig.ConditionPathExists =
    config.services.waywarp.instances.osaka.environmentFile;

  environment.systemPackages = [
    braveWaywarp
    (pkgs.makeDesktopItem {
      name = "brave-waywarp";
      desktopName = "Brave (Waywarp)";
      comment = "Browse inside the waywarp0 network namespace";
      exec = "${braveWaywarp}/bin/brave-waywarp %U";
      icon = "brave-browser";
      categories = [
        "Network"
        "WebBrowser"
      ];
    })
  ];
}
