{ ... }:

{
  imports = [
    ./gpu.nix
    ./bluetooth.nix
  ];
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    wirelessRegulatoryDatabase = true;
    uinput.enable = true;
  };
}
