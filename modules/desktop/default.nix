{
  lib,
  pkgs,
  inputs,
  ...
}:
let
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
    ./theme.nix
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

  # Off by default on Linux in both browsers; Brave's WebGPU needs Vulkan.
  programs.firefox = {
    enable = true;
    preferences."dom.webgpu.enabled" = true;
    preferencesStatus = "default";
  };
  nixpkgs.overlays = [
    (_: prev: { brave = prev.brave.override { enableVulkan = true; }; })
  ];

  # Defaults for types more than one installed app claims; without them GIO
  # picks another browser or VS Code. Other types resolve to their only
  # handler, and ~/.config/mimeapps.list still takes precedence.
  environment.etc."xdg/mimeapps.list".source = ../../files/mimeapps.list;

  security.polkit.extraConfig = builtins.readFile ../../files/polkit/udisks.rules;

  environment.systemPackages = [
    pkgs.alacritty
    pkgs.alacritty.terminfo
    pkgs.brave
    pkgs.brightnessctl
    pkgs.celluloid
    pkgs.flameshot
    pkgs.libva-utils
    pkgs.loupe
    pkgs.nautilus
    pkgs.nixd
    pkgs.remmina
    pkgs.vesktop
    pkgs.vscode-fhs
    pkgs.wl-clipboard
    persway
  ];
}
