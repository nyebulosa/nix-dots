{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://attic.xuyh0120.win/lantian"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
  };

  programs.nh = {
    enable = true;
    flake = "/home/leonillo/nixos-conf";
    clean = {
      enable = true;
      extraArgs = "--keep-since 30d --keep 5";
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];
  };

  home-manager.backupFileExtension = "hmbak";

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      (pkgs.runCommand "steamrun-lib" { }
        "mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib"
      ) # This includes the default libraries in the steam-run thingy
    ];
  };
}
