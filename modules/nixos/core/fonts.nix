{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.symbols-only
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
      nanum # Orca slicer crashes without ts it seems
      liberation_ttf
      helvetica-neue-lt-std
      geist-font
      iosevka
    ];
    enableDefaultPackages = true;
    # fontconfig = {
    #   antialias = true;
    #   cache32Bit = true;
    #   hinting = {
    #     enable = true;
    #     #autohint = true;
    #   };
    #   subpixel = {
    #     rgba = "rgb";
    #     lcdfilter = "default";
    #   };
    # };
  };
}
