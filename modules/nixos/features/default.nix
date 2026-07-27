{ lib, ... }:

{
  imports = [
    ./niri.nix
    ./gaming.nix
    ./illuminanced.nix
  ];

  my = {
    gaming.enable = lib.mkDefault true;
    illuminanced.enable = lib.mkDefault false;
  };
}
