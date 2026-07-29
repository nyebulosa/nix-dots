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
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open Steam remote play and dedicated server ports";
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        extest.enable = true;
        remotePlay.openFirewall = cfg.openFirewall;
        dedicatedServer.openFirewall = cfg.openFirewall;
      };
      gamemode.enable = true;
      gamescope = {
        enable = true;
        args = [
          "--expose-wayland"
          "--adaptive-sync"
        ];
        # package = pkgs.gamescope.overrideAttrs (_: {
        #   NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
        # });
      };
    };
  };
}
