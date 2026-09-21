{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.gaming;
  mcJDKs = with pkgs; [
    temurin-jre-bin-8
    temurin-jre-bin-25
    temurin-jre-bin
    zulu25
  ];
in
{
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming" // {
      default = true;
    };
    openFirewall = lib.mkEnableOption "Gaming-related ports" // {
      default = false;
    };
    vrInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "eno1";
      description = ''
        Interface the wireless VR router hangs off. DNS/DHCP are only opened
        there; null opens them on every interface.
      '';
    };
    enableReplay = lib.mkEnableOption "quick replay via gpu-screen-recorder" // {
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall (
      let
        # DNS + DHCP served to the wireless VR router
        vrPorts = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [
            53
            67
          ];
        };
      in
      lib.mkMerge [
        {
          allowedTCPPorts = [ 25565 ]; # Minecraft
          allowedUDPPorts = [ 24454 ]; # Simple Voice Chat
        }
        (if cfg.vrInterface == null then vrPorts else { interfaces.${cfg.vrInterface} = vrPorts; })
      ]
    );

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

    users.users.${config.my.user.name}.extraGroups = [ "gamemode" ];

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     lsfg-vk-experimental = final.callPackage ../../../pkgs/lsfg-vk-experimental.nix { };
    #   })
    # ];

    environment.systemPackages = with pkgs; [
      parsec-bin
      heroic
      (prismlauncher.override {
        jdks = mcJDKs;
        additionalPrograms = [ vlc ];
        additionalLibs = [
          vlc
          opencl-headers
          ocl-icd
        ];
      })
      r2modman
      bs-manager
      lsfg-vk
      lsfg-vk-ui
      # lsfg-vk-experimental
      (pandora-launcher.override {
        jdks = mcJDKs;
        additionalPrograms = [ vlc ];
        additionalLibs = [
          vlc
          opencl-headers
          ocl-icd
        ];
      })
    ];
  };
}
