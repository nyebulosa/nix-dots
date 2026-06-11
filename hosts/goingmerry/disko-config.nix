#
#    Configuration for Disko, for declarative partitioning
#

let
  btrfsOptions = [
    "compress=zstd:2"
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
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # ESP/Boot partition, for systemd-boot or grub (haven't decided)
            ESP = {
              # Set size to 1G, necessary for systemd-boot, and type EF00, which means efi boot partition
              size = "1G";
              type = "EF00";
              # Set Filesystem to FAT32, and mountpoint to /boot
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            # 16G swap partition. Unnecesarily big, but storage is not a problem YET
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };

            # Root partition, formatted with btrfs
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Enables overriding existing btrfs partitions
                # Create subvolumes @ for /, @home for /home, @nix for /nix, and @log for /var/log,
                # all of them with compress=zstd:2 for good balance between performance and compression,
                # and some additional optimizations, options defined in the let at the start of the file
                subvolumes = {
                  "@" = {
                    mountOptions = btrfsOptions;
                    mountpoint = "/";
                  };
                  "@home" = {
                    mountOptions = btrfsOptions ++ [
                      # "nosuid"
                      # "nodev"
                      # "noexec"
                    ];
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = btrfsOptions;
                    mountpoint = "/nix";
                  };
                  "@log" = {
                    mountOptions = btrfsOptions ++ [
                      # "nosuid"
                      # "nodev"
                      # "noexec"
                    ];
                    mountpoint = "/var/log";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
