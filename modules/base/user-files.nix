{ config, lib, ... }:
{
  options.dotfiles.userFiles = lib.mkOption {
    type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.str);
    default = { };
    description = ''
      Read-only files symlinked into every user's home by systemd-tmpfiles,
      keyed by path relative to the home directory. Applications that rewrite
      their configuration need a writable copy instead.
    '';
  };

  config.systemd.user.tmpfiles.rules = lib.mapAttrsToList (
    target: source: "L+ %h/${target} - - - - ${source}"
  ) config.dotfiles.userFiles;
}
