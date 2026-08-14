{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.power;
in
{
  options.my.power = {
    laptop = lib.mkEnableOption "runtime power management for battery-powered hosts" // {
      default = false;
    };
    scx = lib.mkEnableOption "the scx_lavd sched_ext scheduler on top of BORE" // {
      default = true;
    };
    chargeLimit = lib.mkOption {
      type = lib.types.ints.between 50 100;
      default = 80;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.scx {
      services.scx = {
        enable = true;
        scheduler = lib.mkDefault "scx_lavd";
        extraArgs = lib.mkDefault [ (if cfg.laptop then "--autopower" else "--performance") ];
      };
    })

    (lib.mkIf cfg.laptop {
      services.power-profiles-daemon.enable = true;
      networking.networkmanager.wifi.powersave = true;
      boot.kernelParams = [ "pcie_aspm.policy=powersave" ];
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
      '';

      # cros_charge_control only adds charge_control_end_threshold once it binds,
      # ~26s into boot and with no uevent, so udev's coldplug pass always misses it
      systemd.services.battery-charge-limit = {
        description = "Apply the battery charge end threshold";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.coreutils ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          for _ in $(seq 60); do
            for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
              if [ -w "$f" ]; then
                echo ${toString cfg.chargeLimit} > "$f"
                exit 0
              fi
            done
            sleep 1
          done
          exit 1
        '';
      };
    })
  ];
}
