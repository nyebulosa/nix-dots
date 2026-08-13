{
  config,
  lib,
  pkgs,
  ...
}:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "mauve";
    flavor = "mocha";
    plymouth.enable = false;
    tty.enable = false; # Emits 32 vt.default_* colours, the kernel takes 16
  };
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      kmscon.enable = false;
      plymouth.enable = false;
      console.enable = true; # Themes the tty via console.colors instead
    };
  };
}
