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
    # wluma.enable = true;
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
    amdgpu = {
      overdrive.enable = false;
      # Blocky full-screen corruption on the internal panel. nixos-hardware
      # already disables PSR (0x10); Panel Replay (0x400) is its successor on
      # newer kernels and glitches the same way on the 7040 series.
      dcDebugMask.disableReplay = true;
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-lto-znver4; # Ryzen 5 7640U
    resumeDevice = "/dev/disk/by-uuid/6347b813-8e2a-47de-8a75-b5d86483bb99";
    kernelParams = lib.mkAfter [
      "resume_offset=533760"
      # Scan out from the VRAM carve-out instead of system RAM; avoids the
      # scatter/gather display path, which also produces garbled frames and
      # interacts badly with amd_iommu=force_isolation.
      "amdgpu.sg_display=0"
      "zswap.enabled=1" # to avoid conflict with hibernation, disabling zram in this host
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=25"
    ];
    kernel.sysctl = {
      "vm.swappiness" = lib.mkForce 60;
    };
  };

  services = {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
    fprintd.enable = true;
    fwupd.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandlePowerKey = "suspend-then-hibernate";
    };
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 7;
      percentageAction = 5;
      # criticalPowerAction = "Hibernate";
      # noPollBatteries = true;
    };
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "60min";

  zramSwap.enable = false;

  environment.systemPackages = with pkgs; [
    framework-tool
  ];

  # Hostname Configuration, used so I don't have to use --flake on rebuild
  networking.hostName = "goingmerry";
}
