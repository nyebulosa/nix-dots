{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

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

  # Fixes a bug that causes lots and lots of lag. and some power saving.
  boot = {
    kernelParams = [
      "amdgpu.dcdebugmask=0x0"
      "pcie_aspm=force"
      "pcie_aspm.policy=powersave"
    ];
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    lanzaboote.configurationLimit = 5; # 512M ESP
  };

  networking.networkmanager.wifi.powersave = true;

  services = {
    power-profiles-daemon.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
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

  my = {
    illuminanced.enable = false;
    gaming.openFirewall = false;
    gpu.type = "amd";
  };

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
