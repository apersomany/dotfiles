{ config, inputs, ... }:
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
}
