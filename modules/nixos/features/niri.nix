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
    package = pkgs.niri.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "niri-wm";
        repo = "niri";
        rev = "ef4622768e57e641847245178c7953d6730079cd";
        hash = "sha256-rCHu+uCH1bXEyBf7PoH9E8k1Qd55YoYkPNQIuTkSOtw=";
      };
    });
  };
  environment.systemPackages = with pkgs; [
    fuzzel
    inputs.quickshell.packages.x86_64-linux.default
    kdePackages.polkit-kde-agent-1
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
  nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
  services.displayManager = {
    defaultSession = "niri";
    autoLogin = {
      enable = true;
      user = "leonillo";
    };
  };
}
