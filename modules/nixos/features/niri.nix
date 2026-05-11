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
    fuzzel
    inputs.quickshell.packages.x86_64-linux.default
    kdePackages.polkit-kde-agent-1
    xwayland-satellite
    awww
    nemo
    kitty
    waybar
    rofi-power-menu
    rofi-top
    rofi-calc
    rofi-emoji
    rofi-bluetooth
  ];
  systemd.user.services.niri-plasma-polkit-agent = {
    description = "KDE Polkit Agent service for Niri";
    wantedBy = [ "niri.service" ];
    after = [ "grapical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
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
}
