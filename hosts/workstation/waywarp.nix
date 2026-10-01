{ config, inputs, ... }:
{
  imports = [ inputs.waywarp.nixosModules.default ];

  services.waywarp.instances.osaka = {
    index = 0;
    access.bridge = { };
    location = "geo4=JP/Osaka+edge=KIX";
    via = [ "mudfish:city=osaka+provider=azure" ];
    environmentFile = "/var/lib/secrets/waywarp-mudfish.env";
  };

  systemd.services.waywarp-osaka.unitConfig.ConditionPathExists =
    config.services.waywarp.instances.osaka.environmentFile;
}
