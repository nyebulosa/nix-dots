{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  my = {
    gpu.type = "amd";
  };

  # Hardware Configuration
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    framework = {
      enableKmod = true;
      laptop13 = {
        audioEnhancement = {
          enable = true;
          hideRawDevice = false;
        };
      };
    };
  };
  # environment.variables = {
  #   RUSTICL_ENABLE = "radeonsi";
  # };

  # Fixes a bug that causes lots and lots of lag
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x0"
    "amd_pstate=active"
    "pcie_aspm=force"
    "pcie_aspm.policy=powersave"
  ];

  services = {
    power-profiles-daemon.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
      #extraArgs = [ "--autopower" ];
    };
  };
  location = {
    latitude = 38.8977;
    longitude = 1.4022;
  };

  environment.systemPackages = with pkgs; [
    framework-tool
    clight-gui
    sbctl
  ];

  programs = {
    coolercontrol.enable = true;
  };

  my = {
    illuminanced.enable = false;
  };

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
