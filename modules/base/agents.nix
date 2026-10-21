{
  pkgs,
  inputs,
  username,
  ...
}:
let
  pnpm = pkgs.pnpm.override { nodejs-slim = pkgs.nodejs-slim_24; };
  claude = pkgs.writeShellApplication {
    name = "claude";
    runtimeInputs = [ pnpm ];
    text = ''
      # pnpm manages updates instead of Claude's native installer.
      export DISABLE_AUTOUPDATER=1
      exec pnpm --config.prefer-online=true \
        --config.minimum-release-age-exclude=@anthropic-ai/claude-code \
        dlx --allow-build=@anthropic-ai/claude-code \
        @anthropic-ai/claude-code@latest "$@"
    '';
  };
  pi = pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [ pnpm ];
    text = ''
      # Revalidate the latest tag on every launch, exempt from the release-age delay.
      exec pnpm --config.prefer-online=true \
        --config.minimum-release-age-exclude=@earendil-works/pi-coding-agent \
        dlx --allow-build=@google/genai --allow-build=protobufjs --allow-build=esbuild \
        @earendil-works/pi-coding-agent@latest "$@"
    '';
  };
in
{
  # herdr-nix's release binaries.
  nix.settings = {
    substituters = [ "https://herdr.cachix.org" ];
    trusted-public-keys = [
      "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
    ];
  };

  fileSystems."/home/${username}/.pi" = {
    overlay = {
      lowerdir = [ "/home/${username}/dotfiles/.pi" ];
      upperdir = "/home/${username}/.local/state/overlays/pi/upper";
      workdir = "/home/${username}/.local/state/overlays/pi/work";
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/${username}/.pi 0755 ${username} users -"
  ];

  environment.systemPackages = [
    inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    claude
    pi
    pnpm
    pkgs.nodejs_24
    pkgs.ffmpeg
  ];
}
