{ lib, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      # font_size = "12.0";
      background_opacity = lib.mkForce "0.8";
      term = "xterm-256color";
      confirm_os_window_close = "-1";
      font_family = "A-OTF Shin Go Pro";
      background = "#1e1e2e";
      #pixel_scroll = "yes";
      #momentum_scroll = 0.5;
    };
  };
}
