{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.gpu;
in
{
  options.my.gpu = {
    type = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "nvidia"
        "intel"
      ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.type == "amd") {
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        amdgpu = {
          opencl.enable = lib.mkDefault true;
          initrd.enable = true;
          overdrive = {
            enable = lib.mkDefault true;
            ppfeaturemask = lib.mkDefault "0xffffffff";
          };
        };
      };
      environment = {
        systemPackages = with pkgs; [
          nvtopPackages.amd
          libva-utils
        ];
      };
      services.lact.enable = lib.mkDefault config.hardware.amdgpu.overdrive.enable;
    })

    (lib.mkIf (cfg.type == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        nvidia = {
          open = lib.mkDefault true;
          powerManagement.enable = lib.mkDefault true;
          nvidiaSettings = lib.mkDefault true;
          package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
        };
      };
      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
    })

    (lib.mkIf (cfg.type == "intel") {
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            intel-compute-runtime
            vpl-gpu-rt
            intel-media-driver
          ];
        };
      };
      environment = {
        sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
        systemPackages = with pkgs; [
          nvtopPackages.intel
        ];
      };
    })
  ];
}
