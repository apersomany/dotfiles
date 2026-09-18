{ pkgs, ... }:
let
  userDirs = pkgs.writeText "user-dirs.dirs" (builtins.readFile ../../files/user-dirs.dirs);
in
{
  systemd.user.tmpfiles.rules = [
    "L+ %h/.config/user-dirs.dirs - - - - ${userDirs}"
  ];
}
