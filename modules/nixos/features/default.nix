{ lib, ... }:

{
  imports = [
    ./niri.nix
    ./gaming.nix
    ./illuminanced.nix
    ./usbguard.nix
  ];
}
