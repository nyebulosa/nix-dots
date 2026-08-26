{ lib, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    #themeFile = "Catppuccin-Mocha";
    settings = {
      # font_size = "12.0";
      background_opacity = lib.mkForce "0.9";
      confirm_os_window_close = "-1";
      font_family = "Geist Mono";
      background = "#1e1e2e";
      #pixel_scroll = "yes";
      #momentum_scroll = 0.5;
      allow_remote_control = "no";
    };
  };
}
