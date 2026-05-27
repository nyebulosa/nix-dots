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
    ./discordkrisp.nix
  ];

  # Hardware Configuration
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        libva
        mesa
      ];
    };
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
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
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

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      pkiBundle = "/var/lib/sbctl";
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
    };
  };

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
  ];

  programs = {
    coolercontrol.enable = true;
  };

  my = {
    illuminanced.enable = true;
  };

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
