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
  # Real `pi` binary on the system PATH so non-interactive consumers can
  # spawn pi. TUI mode comes from the `tuiMode` setting so subcommands like
  # `pi update --extensions` keep their argv[0] command word intact.
  pi = pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [ pnpm ];
    text = ''
      # Revalidate the latest tag on every launch without delaying new Pi releases.
      exec pnpm --config.prefer-online=true \
        --config.minimum-release-age-exclude=@earendil-works/pi-coding-agent \
        dlx --allow-build=@google/genai --allow-build=protobufjs --allow-build=esbuild \
        @earendil-works/pi-coding-agent@latest "$@"
    '';
  };
in
{
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
    pkgs.agent-browser
    pkgs.chromium
    pkgs.ffmpeg
  ];
}
