{ pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  my.gpu.type = "amd";

  # Hardware configuration, this desktop has an AMD GPU
  hardware = {
    keyboard.qmk.enable = true;
  };

  boot = {
    kernelParams = [
      "amd_pstate=guided"
    ];
  };

  powerManagement = {
    powertop.enable = lib.mkForce false; # Disable powertop due to USB issues
    cpuFreqGovernor = "schedutil";
  };

  services = {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--performance" ]; # desktop is always on AC anyways
    };
    sunshine = {
      enable = true;
    };
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

  networking = {
    firewall.allowedUDPPorts = [
      53
      67
      24454
    ];
    firewall.allowedTCPPorts = [
      53
      67
      25565
    ];
    hostName = "thousandsunny"; # with this I don't have to use --flake on rebuild
  };
}
