{ config, inputs, ... }:
{
  imports = [ inputs.waywarp.nixosModules.default ];

  services.waywarp.instances.hkg = {
    index = 0;
    access.proxy.listen = "127.0.0.1:1080";
    location = "geo4=HK+edge=HKG";
    via = [ "mudfish:city=hongkong" ];
    environmentFile = "/var/lib/secrets/waywarp-mudfish.env";
  };

  systemd.services.waywarp-hkg.unitConfig.ConditionPathExists =
    config.services.waywarp.instances.hkg.environmentFile;
}
