{
  config,
  lib,
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
    scx = lib.mkEnableOption "scx_lavd" // {
      default = true;
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
      services = {
        udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
        '';
        upower.enable = true;
      };

    })
  ];
}
