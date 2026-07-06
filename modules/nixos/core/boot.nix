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
        enable = false;
        #   consoleMode = "max";
        #   editor = false; # Better security
        #   configurationLimit = 10;
      };
      limine = {
        enable = true;
        # secureBoot.enable = true;
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
