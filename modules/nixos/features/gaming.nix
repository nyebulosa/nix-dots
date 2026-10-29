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
    graalvmPackages.graalvm-ce
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
    vr.enable = lib.mkEnableOption "gaming" // {
      default = false;
    };
    vr.interface = lib.mkOption {
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
        (if cfg.vr.interface == null then vrPorts else { interfaces.${cfg.vr.interface} = vrPorts; })
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
      alvr = lib.mkIf cfg.vr.enable {
        enable = true;
        openFirewall = cfg.openFirewall;
      };
    };

    services = {
      wivrn = lib.mkIf cfg.vr.enable {
        enable = true;
        highPriority = true;
        openFirewall = cfg.openFirewall;
      };
    };

    users.users.${config.my.user.name}.extraGroups = [ "gamemode" ];

    nixpkgs.overlays = [
      (final: prev: {
        # lsfg-vk-experimental = final.callPackage ../../../pkgs/lsfg-vk-experimental.nix { };

        #
        # AI WARNING
        # This, and all of the pandora launcher stuff, was made with the use of LLMs.
        # It's just for testing and will probably get deleted later.
        #

        # Temporary: upstream master + NixOS sandbox fix, see pkgs/pandora-launcher-git.nix.
        # The pandora-launcher wrapper picks this up automatically through final.
        pandora-launcher-unwrapped = import ../../../pkgs/pandora-launcher-git.nix {
          inherit (final) fetchFromGitHub;
          inherit (prev) pandora-launcher-unwrapped;
        };

        # Temporary, Minecraft 26.3+ (SDL3 instead of GLFW). nixpkgs copied this
        # wrapper from prismlauncher's but dropped the three libraries SDL3
        # dlopens for its Wayland driver. Without them SDL silently falls back to
        # XWayland while LWJGL has already picked EGL (WAYLAND_DISPLAY is set), and
        # the game dies with "OpenGL is not supported: Could not retrieve OpenGL
        # functions". SDL3 makes the same fallback on compositors without fifo-v1
        # (niri), so also force Wayland whenever there is a Wayland display.
        pandora-launcher = prev.pandora-launcher.overrideAttrs (old: {
          makeWrapperArgs = old.makeWrapperArgs ++ [
            "--prefix"
            "LD_LIBRARY_PATH"
            ":"
            (lib.makeLibraryPath [
              final.wayland
              final.libdecor
              final.libxkbcommon
            ])
            "--run"
            ''if [ -n "$WAYLAND_DISPLAY" ]; then export SDL_VIDEO_DRIVER="''${SDL_VIDEO_DRIVER:-wayland}"; fi''
          ];
        });
      })
    ];

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
