{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.niri = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    awww
    nemo-with-extensions
    nemo-fileroller
    nemo-preview
    nemo-python
    nemo-emblems
    gnome-font-viewer
    kitty
    waybar
    cursor-clip
    polkit_gnome
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
      enable = lib.mkDefault false;
      user = "leonillo";
    };
  };
}
