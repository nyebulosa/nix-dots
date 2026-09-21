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
    services.displayManager = {
      defaultSession = "niri";
      autoLogin = {
        enable = lib.mkDefault cfg.autoLogin;
        user = config.my.user.name;
      };
    };
  };
}
