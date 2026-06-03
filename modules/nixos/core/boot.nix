{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true; # This needs to be disabled if using lanzaboote
        consoleMode = "max";
        editor = false; # Better security
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    initrd.systemd.enable = lib.mkDefault true;
    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3; # All my current machines are v3, can be changed per host
    tmp = {
      useTmpfs = true;
      #cleanOnBoot = true; # If not tmps then use this
    };
  };
}
