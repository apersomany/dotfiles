{
  pkgs,
  username,
  userFullName,
  gitUserName,
  gitUserEmail,
  ...
}:
{
  imports = [
    ./boot.nix
    ./agents.nix
    ./sops.nix
    ./user-files.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Seoul";

  security.sudo.wheelNeedsPassword = false;

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "1.0.0.1"
      "8.8.4.4"
    ];
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = false;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  environment = {
    systemPackages = [
      pkgs.gh
      pkgs.nix-search-cli
      pkgs.zip
      pkgs.unzip
      pkgs.ripgrep
      pkgs.jq
      pkgs.fd
      pkgs.killall
      pkgs.uv
      pkgs.rustup
      pkgs.abduco
    ];

    # For binaries not built by Nix, which look for distribution CA paths.
    variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };

  programs = {
    nh = {
      enable = true;
      flake = "/home/${username}/dotfiles";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nix-ld.enable = true;

    bash = {
      promptInit = ''
        export PS1="\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
      '';

      interactiveShellInit = ''
        export PATH="$HOME/.local/bin:$PATH"

        if command -v gh &>/dev/null; then
          export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
        fi
      '';
    };

    git = {
      enable = true;
      config = {
        user = {
          name = gitUserName;
          email = gitUserEmail;
        };
        credential.helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
    };

    ssh.extraConfig = builtins.readFile ../../files/ssh/config;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTLmX82sXKztx9xDV+Ak6ttg5h99PUkoojbPXIOjy7cVDhEwxe/BwtVVQPzbBpUKYe2x3yiDvi5Djuk3ubX87WEmcCrD/d41wkHRh3GD4W+A0l5X9yC8bUpj3hNRZ9rul23kCHN4kRA9e6TTAEsGM8EdWLcLuhm38VdFbGvupTESB3EReS/u0Ti85YCljRpW8rq1Hd2duC3xbGxuti6cTI8uELVHsPNRSQ+Dv6Sb9pniPvd6weOQ45OygVro9sE97XESkcDheTgWLNlXb0EkRhmHE6KmMhfKHLHDPTXIiXyFMt02S7Gr9V+1B69fPLXaz9UpZifSZsnUsA1aD8P+jD"
    ];
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "video"
      "render"
    ];
  };
}
