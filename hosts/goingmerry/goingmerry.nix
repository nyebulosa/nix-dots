{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  my = {
    gpu.type = "amd";
    bluetooth.enable = true;
    network.wifi.enable = true;
    gaming.enable = true;
    power.laptop = true;
  };

  hardware = {
    framework = {
      enableKmod = true;
      laptop13 = {
        audioEnhancement = {
          enable = true;
          hideRawDevice = false;
        };
      };
    };
    amdgpu.overdrive.enable = false;
  };

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
    lanzaboote.configurationLimit = 5;
    # nixos-hardware sets dcdebugmask=0x10 (DC_DISABLE_PSR) for drm/amd#3647.
    # mkAfter puts this last on the cmdline, and the last module param wins.
    kernelParams = lib.mkAfter [ "amdgpu.dcdebugmask=0x0" ];
  };

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
  };
  environment.systemPackages = with pkgs; [
    framework-tool
    clight-gui
  ];

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
