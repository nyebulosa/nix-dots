{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.wluma;
in
{
  options.my.wluma = {
    enable = lib.mkEnableOption "wluma" // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    # nixpkgs ships 4.11.1; this builds upstream `main`, whose predictor works
    # on continuous lux instead of named buckets. See pkgs/wluma-git.nix.
    nixpkgs.overlays = [
      (final: _prev: {
        wluma = final.callPackage ../../../pkgs/wluma-git.nix { };
      })
    ];

    # Upstream's 90-wluma-backlight.rules
    # https://github.com/max-baz/wluma/blob/main/90-wluma-backlight.rules
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", \
        RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
        RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", \
        RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness", \
        RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
    '';
  };
}
