{
  config,
  lib,
  pkgs,
  ...
}:
{

  boot = {
    initrd = {
      systemd = {
        enable = true;
        services.rollback = {
          description = "Rollback BTRFS for impermanence";
          wantedBy = [ "initrd.target" ];
          after = [ "systemd-cryptsetup@crypted.service" ];
          before = [ "sysroot.mount" ];
          requires = [ "systemd-cryptsetup@crypted.service" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          path = [ pkgs.btrfs-progs ];

          script = ''
            mkdir /btrfs_tmp
            mount /dev/mapper/crypted /btrfs_tmp
            if [[ -e /btrfs_tmp/@ ]]; then
                mkdir -p /btrfs_tmp/old_roots
                timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
                mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
            fi

            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/btrfs_tmp/$i"
                done
                btrfs subvolume delete "$1"
            }

            for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
                delete_subvolume_recursively "$i"
            done

            btrfs subvolume create /btrfs_tmp/@
            umount /btrfs_tmp
          '';
        };
      };
    };
  };
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    allowTrash = true;
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
