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
  options.my.illuminanced.enable = lib.mkEnableOption "illuminanced";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      illuminanced
    ];
    systemd.services.illuminanced = {
      description = "Ambient Light Sensor Daemon for Linux";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.illuminanced}/bin/illuminanced -c ~/.config/illuminanced/illuminanced.toml";
        Restart = "always";
      };
    };
  };
}
