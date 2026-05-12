{ lib, ... }:

{
  imports = [
    ./niri.nix
    ./gaming.nix
  ];

  my = {
    gaming.enable = lib.mkDefault true;
  };
}
