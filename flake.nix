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
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              self
              inputs
              username
              userFullName
              gitUserName
              gitUserEmail
              ;
          };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            (./. + "/hosts/${name}/configuration.nix")
          ];
        };
    in
    {
      nixosConfigurations.workstation = mkHost "workstation";
      nixosConfigurations.scg-workstation = mkHost "scg-workstation";

      formatter.x86_64-linux = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.treefmt
          pkgs.nixfmt
        ];
        text = ''
          exec treefmt "$@"
        '';
      };

      checks.x86_64-linux = {
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

        format = pkgs.runCommand "format" { nativeBuildInputs = [ self.formatter.x86_64-linux ]; } ''
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

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.statix
          pkgs.deadnix
        ];
      };
    };
}
