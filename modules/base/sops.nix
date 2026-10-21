{ inputs, pkgs, ... }:
{
  # Hosts decrypt with their SSH host key.
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.ssh-to-age
  ];
}
