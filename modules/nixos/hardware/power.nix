{ config, lib, ... }:
let
  cfg = config.my.power;
in
{
  options.my.power = {
    laptop = lib.mkEnableOption "runtime power management for battery-powered hosts" // {
      default = false;
    };
    chargeLimit = lib.mkOption {
      type = lib.types.ints.between 50 100;
      default = 80;
    };
  };

  config = lib.mkMerge [
    {
      services.scx = {
        enable = lib.mkDefault true;
        scheduler = lib.mkDefault "scx_lavd";
        extraArgs = lib.mkDefault [ (if cfg.laptop then "--autopower" else "--performance") ];
      };
    }

    (lib.mkIf cfg.laptop {
      services.power-profiles-daemon.enable = true;
      networking.networkmanager.wifi.powersave = true;
      boot.kernelParams = [ "pcie_aspm.policy=powersave" ];
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
        ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", ATTR{charge_control_end_threshold}=="?*", ATTR{charge_control_end_threshold}="${toString cfg.chargeLimit}"
      '';
    })
  ];
}
