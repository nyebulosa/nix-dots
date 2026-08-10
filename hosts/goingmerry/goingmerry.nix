{
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
    kernelParams = [
      "pcie_aspm=force"
      "pcie_aspm.policy=powersave"
    ];
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    lanzaboote.configurationLimit = 5;
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
  environment.systemPackages = with pkgs; [
    framework-tool
    clight-gui
  ];

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
