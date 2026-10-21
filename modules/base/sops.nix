{ inputs, pkgs, ... }:
{
  # Hosts decrypt with their SSH host key (sops-nix's default when openssh is
  # enabled). Secrets must only gate optional services so a freshly installed
  # host, whose key is not yet a recipient, still boots normally.
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.ssh-to-age
  ];
}
