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
    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.illuminanced}/share/illuminanced/illuminanced.toml";
      defaultText = lib.literalExpression "\${pkgs.illuminanced}/share/illuminanced/illuminanced.toml";
      description = "Config passed to illuminanced -c. The daemon runs as root, so this must not be user-writable.";
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

    systemd.services.illuminanced = {
      description = "Ambient Light Sensor Daemon for Linux";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.illuminanced}/bin/illuminanced -c ${cfg.configFile}";
        Restart = "on-failure";
        ProtectHome = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateNetwork = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
