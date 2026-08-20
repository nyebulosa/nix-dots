{
  pkgs,
  lib,
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
    wluma.enable = true;
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
    resumeDevice = "/dev/disk/by-uuid/6347b813-8e2a-47de-8a75-b5d86483bb99";
    kernelParams = lib.mkAfter [
      "amdgpu.dcdebugmask=0x0" # Testing this
      "resume_offset=533760"
    ];
  };

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend";
    };
    upower = {
      criticalPowerAction = "Hibernate";
      noPollBatteries = true;
    };
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "60min";

  environment.systemPackages = with pkgs; [
    framework-tool
  ];

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
