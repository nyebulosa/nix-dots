{ ... }:
{
  imports = [
    ./boot.nix
    ./systemd.nix
    ./nix.nix
    ./hardening.nix
    ./performance.nix
    ./impermanence.nix
    ./network.nix
    ./fonts.nix
    ./polkit.nix
  ];
}
