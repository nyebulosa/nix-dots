{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.gaming;
in
{
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming" // {
      default = true;
    };
    openFirewall = lib.mkEnableOption "Gaming-related ports" // {
      default = false;
    };
    enableReplay = lib.mkEnableOption "quick replay via gpu-screen-recorder" // {
      default = true;
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
      gpu-screen-recorder.enable = cfg.enableReplay;
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

    users.users.leonillo.extraGroups = [ "gamemode" ];

    nixpkgs.overlays = [
      (final: prev: {
        lsfg-vk-experimental = final.callPackage ../../../pkgs/lsfg-vk-experimental.nix { };
      })
      (final: prev: {
        lsfg-vk-ui-experimental = final.callPackage ../../../pkgs/lsfg-vk-ui-experimental.nix { };
      })
    ];

    environment.systemPackages = with pkgs; [
      parsec-bin
      heroic
      (prismlauncher.override {
        jdks = [
          temurin-jre-bin-8
          temurin-jre-bin-25
          temurin-jre-bin
          zulu25
        ];
        additionalPrograms = [ vlc ];
        additionalLibs = [
          vlc
          opencl-headers
          ocl-icd
        ];
      })
      r2modman
      bs-manager
      # lsfg-vk
      # lsfg-vk-ui
      lsfg-vk-experimental
      lsfg-vk-ui-experimental
    ];
  };
}
