{ ... }:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  my = {
    gpu.type = "amd";
    # Desktop hosts the game/VR-router services, so open the gaming ports here
    # (these used to be hardcoded in networking.firewall below)
    gaming.openFirewall = true;
  };

  # Hardware configuration, this desktop has an AMD GPU
  hardware = {
    keyboard.qmk.enable = true;
  };

  boot = {
    kernelParams = [
      "amd_pstate=guided"
    ];
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  # services = {
  #   sunshine = {
  #     enable = true;
  #   };
  # };

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
    # gaming ports moved to my.gaming.openFirewall
    hostName = "thousandsunny"; # with this I don't have to use --flake on rebuild
  };
}
