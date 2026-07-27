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
      type = lib.types.enum [ "amd" "nvidia" "intel" "hybrid-amd-nvidia" "none" ];
      default = "amd";
    };

    amd = {
      opencl = lib.mkEnableOption "AMD OpenCL (ROCM)";
      zluda = lib.mkEnableOption "AMD ZLUDA";
    };

    nvidia = {
      open = lib.mkEnableOption "NVIDIA open-source kernel modules";
    };
  };

  config = lib.mkMerge [
    {
      hardware.graphics = {
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
        extraPackages = with pkgs; [
          vulkan-loader
          libva
          mesa
        ];
      };
    }

    (lib.mkIf (cfg.type == "amd") {
      hardware.amdgpu = {
        initrd.enable = true;
        opencl.enable = cfg.amd.opencl;
        zluda.enable = cfg.amd.zluda;
      };
      environment.variables = {
        AMD_VULKAN_ICD = "RADV";
      };
      environment.systemPackages = with pkgs; [
        nvtopPackages.amd
      ];
    })

    (lib.mkIf (cfg.type == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = cfg.nvidia.open;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
    })

    (lib.mkIf (cfg.type == "intel") {
      environment.systemPackages = with pkgs; [
        intel-gpu-tools
        nvtopPackages.intel
      ];
    })

    (lib.mkIf (cfg.type == "hybrid-amd-nvidia") {
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = cfg.nvidia.open;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        prime = {
          amdgpuBusId = "PCI:5:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      hardware.amdgpu = {
        initrd.enable = true;
        opencl.enable = cfg.amd.opencl;
      };
      environment.variables = {
        AMD_VULKAN_ICD = "RADV";
      };
      environment.systemPackages = with pkgs; [
        nvtopPackages.amd
        nvtopPackages.nvidia
      ];
    })
  ];
}
