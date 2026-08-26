{ config, lib, ... }:
let
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
    enable = lib.mkEnableOption "bluetooth support" // {
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
}
