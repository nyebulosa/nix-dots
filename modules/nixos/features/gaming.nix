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
      description = "Open Steam, Minecraft and wireless VR router ports";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        53 # DNS, for the wireless VR router
        67 # DHCP
        25565 # Minecraft
      ];
      allowedUDPPorts = [
        53
        67
        24454 # Simple Voice Chat
      ];
    };
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
