{ pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  # Hardware configuration, this desktop has an AMD GPU
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        libva
        libva-utils
        mesa
        #mesa.opencl
      ];
    };
    bluetooth.enable = true;
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
      overdrive = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
      zluda.enable = true;
    };
    keyboard.qmk.enable = true;
  };
  # systemd.tmpfiles.rules = let
  #   rocmEnv = pkgs.symlinkJoin {
  #     name = "rocm-combined";
  #     paths = with pkgs.rocmPackages; [
  #       clr
  #       clr.icd
  #       #rocblas
  #       #hipblas
  #       #rpp
  #     ];
  #   };
  # in [
  #   "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  # ];
  #
  #environment.variables = {
  #  RUSTICL_ENABLE = "radeonsi";
  #};

  boot = {
    kernelParams = [
      "amd_pstate=active"
    ];
    kernel.sysctl."net.ipv4.ip_forward" = 1;
    #supportedFilesystems = [ "nfs" ];
  };

  powerManagement = {
    powertop.enable = lib.mkForce false; # Disable powertop due to USB issues
    cpuFreqGovernor = "performance";
  };

  services = {
    #fwupd.enable = true;
    #rpcbind.enable = true; # needed for nfs
    resolved.dnssec = lib.mkForce "true";
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
    sunshine = {
      enable = true;
      capSysAdmin = true;
    };
    #avahi.enable = false;
  };

  fileSystems = {
    "/media/DiscoExtra" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400S37960G_50026B7381CEE10E-part1";
      fsType = "btrfs";
      options = [
        "discard=async"
        "noatime"
        "compress-force=zstd:4"
        "space_cache=v2"
      ];
    };
  };

  systemd = {
    #mounts = [{
    #  type = "nfs";
    #  mountConfig = {
    #    Options = "noatime";
    #  };
    #  what = "192.168.1.96:/Datos";
    #  where = "/media/NAS";
    #}];
    #automounts = [{
    #  wantedBy = [ "multi-user.target" ];
    #  automountConfig = {
    #    TimeoutIdleSec = "600";
    #  };
    #  where = "/media/NAS";
    #}];
    # Setup lact and lactd
    packages = with pkgs; [ lact ];
    services.lactd.wantedBy = [ "multi-user.target" ];
    services.libvirtd.wantedBy = lib.mkForce [ ];
  };

  networking = {
    #firewall.allowedTCPPorts = [ 25565 ]; # Allow Minecraft server port in case I want to host
    firewall.allowedUDPPorts = [
      53
      67
    ];
    firewall.allowedTCPPorts = [
      53
      67
    ];
    hostName = "thousandsunny"; # with this I don't have to use --flake on rebuild
  };

  environment.systemPackages = with pkgs; [
    lact
    nvtopPackages.amd
  ];
}
