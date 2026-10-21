{
  description = "Donghyun Shin's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    herdr-nix.url = "github:herdrdev/herdr-nix";
    kime = {
      url = "github:riey/kime";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    persway = {
      url = "github:saylesss88/persway";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waywarp = {
      url = "github:apersomany/waywarp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      username = "aperso";
      userFullName = "Donghyun Shin";
      gitUserName = "apersomany";
      gitUserEmail = "aperso@aperso.dev";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              username
              userFullName
              gitUserName
              gitUserEmail
              ;
          };
          modules = [
            ./hosts/${name}/configuration.nix
            { networking.hostName = name; }
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs (builtins.attrNames (builtins.readDir ./hosts)) mkHost;

      formatter.${system} = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.treefmt
          pkgs.nixfmt
        ];
        text = ''
          exec treefmt "$@"
        '';
      };

      checks.${system} = {
        lint =
          pkgs.runCommand "lint"
            {
              nativeBuildInputs = [
                pkgs.statix
                pkgs.deadnix
              ];
            }
            ''
              cd ${self}
              statix check .
              deadnix --fail .
              touch $out
            '';

        format = pkgs.runCommand "format" { nativeBuildInputs = [ self.formatter.${system} ]; } ''
          cp -r ${self} src
          chmod -R u+w src
          cd src
          HOME=$TMPDIR treefmt --ci
          touch $out
        '';
      }
      // nixpkgs.lib.mapAttrs' (
        name: host: nixpkgs.lib.nameValuePair "host-${name}" host.config.system.build.toplevel
      ) self.nixosConfigurations;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.statix
          pkgs.deadnix
        ];
      };
    };
}
