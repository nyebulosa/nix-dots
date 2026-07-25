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
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
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
                    "-L"
                    "nixroot"
                  ]; # Enables overriding existing btrfs partitions and sets label
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
                        "nosuid"
                        "nodev"
                        # "noexec" # noexec disabled here and in others because of possible problems
                      ];
                      mountpoint = "/home";
                    };
                    "@nix" = {
                      mountOptions = btrfsOptions;
                      mountpoint = "/nix";
                    };
                    "@log" = {
                      mountOptions = btrfsOptions ++ [
                        "nosuid"
                        "nodev"
                        # "noexec"
                      ];
                      mountpoint = "/var/log";
                    };
                    "@persist" = {
                      mountpoint = "/persistent";
                      mountOptions = btrfsOptions ++ [
                        "nosuid"
                        "nodev"
                        "noexec"
                      ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "16G";
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
}
