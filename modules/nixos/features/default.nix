{ lib, ... }:

{
  imports = [
    ./niri.nix
    ./gaming.nix
    ./usbguard.nix
    ./colorscheme.nix
    ./illuminanced.nix
    ./wluma.nix
  ];
}
