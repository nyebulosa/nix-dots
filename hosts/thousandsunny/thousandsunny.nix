{ ... }:

{
  imports = [
    ./hardware.nix
    ./disko-config.nix
  ];

  my = {
    gpu.type = "amd";
    gaming.openFirewall = true;
    bluetooth.enable = true;
  };

  hardware = {
    keyboard.qmk.enable = true;
  };

  boot = {
    kernelParams = [
      "amd_pstate=guided"
    ];
  };

  powerManagement.cpuFreqGovernor = "schedutil";

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
