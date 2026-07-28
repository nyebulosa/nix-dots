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
          extraPackages = with pkgs; [
            libva
            libva-utils
            vulkan-loader
          ];
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
        variables = {
          AMD_VULKAN_ICD = "RADV";
        };
        systemPackages = with pkgs; [
          nvtopPackages.amd
        ];
      };
      # services.lact.enable = true;
    })

    (lib.mkIf (cfg.type == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        nvidia = {
          # modesetting.enable = true;
          powerManagement = lib.mkDefault {
            enable = true;
            finegrained = true;
          };
          # open = true;
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
