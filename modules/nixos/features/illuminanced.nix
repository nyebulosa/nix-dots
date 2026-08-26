{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.illuminanced;
in
{
  options.my.illuminanced = {
    enable = lib.mkEnableOption "illuminanced" // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.illuminanced ];

    # Allow the service user to write to the backlight sysfs node
    services.udev.extraRules = ''
      SUBSYSTEM=="backlight", ACTION=="add", \
        RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
        RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';
  };
}
