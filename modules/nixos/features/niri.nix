{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.niri;
in
{
  options.my.niri = {
    enable = lib.mkEnableOption "niri" // {
      default = true;
    };
    autoLogin = lib.mkEnableOption "automatic niri login" // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      awww
      kitty
      waybar
    ];
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = false;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };
    # nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

    # 0.8.2 focuses override-redirect windows, so Steam's menus close instantly
    # https://github.com/Supreeeme/xwayland-satellite/issues/468
    # Drop once nixpkgs ships a release newer than 0.8.2
    nixpkgs.overlays = [
      (final: prev: {
        xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: rec {
          version = "0.8.2-unstable-2026-09-09";
          src = final.fetchFromGitHub {
            owner = "Supreeeme";
            repo = "xwayland-satellite";
            rev = "add2795134593faafce60e404a0a75df68e9ee0c";
            hash = "sha256-0TxfMgqW0/BLD4M942c5DCKYrtPvzsPJwvdcco4LQUM=";
          };
          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "${old.pname}-${version}";
            hash = "sha256-s1gl9eR6Mt2QLrhfcowstPFjzwE/lz4PJhJzWYHoIHg=";
          };
        });
      })
    ];
    services.displayManager = {
      defaultSession = "niri";
      autoLogin = {
        enable = lib.mkDefault cfg.autoLogin;
        user = config.my.user.name;
      };
    };
  };
}
