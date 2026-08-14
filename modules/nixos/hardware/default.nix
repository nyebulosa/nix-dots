{ ... }:

{
  imports = [
    ./gpu.nix
    ./bluetooth.nix
    ./power.nix
    ./brightness.nix
  ];
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    wirelessRegulatoryDatabase = true;
    uinput.enable = true;
  };
}
