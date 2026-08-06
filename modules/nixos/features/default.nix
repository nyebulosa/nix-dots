{ lib, ... }:

{
  imports = [
    ./niri.nix
    ./gaming.nix
    ./illuminanced.nix
    ./usbguard.nix
  ];

  my = {
    gaming.enable = lib.mkDefault true;
    illuminanced.enable = lib.mkDefault false;
    usbguard.enable = lib.mkDefault false;
  };
}
