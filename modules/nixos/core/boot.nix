{
  lib,
  pkgs,
  ...
}:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        consoleMode = "max";
      };
      # limine = {
      #   enable = true;
      #   secureBoot.enable = true;
      # };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = lib.mkDefault 8;
      # autoGenerateKeys.enable = true;
      measuredBoot = {
        enable = true;
        pcrs = [
          0
          1
          2
          3
          4
          7
        ];
      };
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
      kernelModules = [ "amdgpu" ];
      verbose = false;
    };
    tmp = {
      useTmpfs = true;
      #cleanOnBoot = true; # If not tmpfs then use this
    };

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];
  };

  environment.systemPackages = with pkgs; [ tpm2-tss ];

  security.tpm2 = {
    enable = true;
  };
}
