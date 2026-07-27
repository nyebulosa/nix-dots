{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
      # limine = {
      #   enable = true;
      #   secureBoot.enable = true;
      # };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    initrd = {
      systemd = {
        enable = lib.mkDefault true;
        tpm2.enable = true;
      };
      availableKernelModules = [
        "tpm_crb"
        "tpm_tis"
      ];
    };
    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3; # All my current machines are v3, can be changed per host
    tmp = {
      useTmpfs = true;
      #cleanOnBoot = true; # If not tmps then use this
    };
  };

  environment.systemPackages = with pkgs; [ tpm2-tss ];

  security.tpm2 = {
    enable = true;
  };
}
