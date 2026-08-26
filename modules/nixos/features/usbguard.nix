{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.usbguard;
in
{
  options.my.usbguard = {
    enable = lib.mkEnableOption "USBGuard" // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.usbguard = {
      enable = true;
      # Trust whatever is attached at boot so the machine can never block its
      # own keyboard; only hotplugged devices need explicit approval
      # (`usbguard list-devices` / `usbguard allow-device <id> -p`).
      # This is a security tradeoff.
      presentDevicePolicy = "allow";
      implicitPolicyTarget = "block";
      IPCAllowedGroups = [ "wheel" ];
    };
    environment.systemPackages = [ pkgs.usbguard ];
  };
}
