{
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  # boot = {
  #   kernel = {
  #     sysctl = {
  #       "net.core.bpf_jit_harden" = 1;
  #     };
  #   };
  # };

  nix-mineral = {
    enable = true;
    preset = [
      # "compatibility"
      "performance"
    ];
    # Some of the disabled settings here are either
    # because of incompatibilities or for performance.
    # I'm considering moving them into performance.nix.
    settings = {
      system = {
        multilib = true;
      };
      network = {
        tcp-sack = true;
      };
      kernel = {
        zero-alloc = true;
        bdev-write-mount = true; # Disabling this breaks hibernation on swapfile
      };
      # debug.debugfs = true;
    };
    filesystems = {
      enable = false;
      normal = {
        "/var/log".options.bind = false;
        "/home".options.bind = false;
        "/tmp".options.noexec = false;
      };
    };
  };

  # boot.kernelParams = lib.mkAfter [
  #   "init_on_alloc=1"
  # ];

  security = {
    sudo.enable = lib.mkForce false;
    run0 = {
      enable = true;
      persistentAuth = {
        enable = true;
        enableRemote = true;
      };
    };
  };

  # environment = {
  #   memoryAllocator.provider = "scudo";
  #   variables.SCUDO_OPTIONS = lib.mkDefault "zero_contents=false";
  # };
}
