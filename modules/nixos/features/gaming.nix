{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.gaming;
in
{
  options.my.gaming.enable = lib.mkEnableOption "gaming";
  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
      };
      gamemode.enable = true;
      gamescope = {
        enable = true;
        args = [
          "--expose-wayland"
          "--adaptive-sync"
        ];
        package = pkgs.gamescope.overrideAttrs (_: {
          NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
        });
      };
    };
  };
}
