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
    ffmpegthumbnailer
    gnome-font-viewer
    kitty
    waybar
    cursor-clip
    pkgs.polkit_gnome
  ];
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
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
      enable = true;
      user = "leonillo";
    };
  };
}
