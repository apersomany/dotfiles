{ pkgs, username, ... }:
let
  # Real `pi` binary on the system PATH so non-interactive consumers can
  # spawn pi. TUI mode comes from the `tuiMode` setting so subcommands like
  # `pi update --extensions` keep their argv[0] command word intact.
  pi = pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [ pkgs.pnpm ];
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

  environment.systemPackages = [ pi ];
}
