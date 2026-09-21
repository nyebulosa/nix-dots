#
#    Configuration for Disko, for declarative partitioning
#

let
  btrfsOptions = [
    "compress=zstd:1"
    "noatime"
    "space_cache=v2"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENJ0Y229274J";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Without this the ESP is world-readable and systemd flags the
                # boot loader random seed as a security hole
                mountOptions = [
                  "umask=0077"
                  "shortname=winnt"
                ];
              };
            };

            luks = {
              size = "100%";
              content = {
                name = "crypted";
                type = "luks";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                    "tpm2-measure-pcr=yes"
                  ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                  ]; # Enables overriding existing btrfs partitions and sets label
                  # Create subvolumes @ for /, @home for /home, @nix for /nix, @log for
                  # /var/log, and @persist for /persist (impermanence). No swap subvolume:
                  # this is a desktop with no hibernation, so it runs zram-only.
                  subvolumes = {
                    "@" = {
                      mountOptions = btrfsOptions ++ [
                        "nosuid"
                        "nodev"
                      ];
                      mountpoint = "/";
                    };
                    "@home" = {
                      mountOptions = btrfsOptions ++ [
                        "nosuid"
                        "nodev"
                        # "noexec" # noexec disabled here and in others because of possible problems
                      ];
                      mountpoint = "/home";
                    };
                    "@nix" = {
                      mountOptions = btrfsOptions ++ [
                        "nodev"
                      ];
                      mountpoint = "/nix";
                    };
                    "@log" = {
                      mountOptions = btrfsOptions ++ [
                        "nosuid"
                        "nodev"
                        "noexec"
                      ];
                      mountpoint = "/var/log";
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = btrfsOptions;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/persist" = {
      neededForBoot = true;
      #     fsType = "btrfs";
      #     device = "dm-uuid-CRYPT-LUKS2-...-crypted";
    };
  };

}
