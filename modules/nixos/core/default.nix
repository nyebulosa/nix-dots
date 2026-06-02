{ ... }:
{
  imports = [
    ./boot.nix
    ./systemd.nix
    ./nix.nix
    ./hardening.nix
  ];
}
