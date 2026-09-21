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
      # "compatibility" # I think ima do this manually
      "performance"
    ];
    # Some of the disabled settings here are either
    # because of incompatibilities or for performance.
    # I'm considering moving them into performance.nix.
    settings = {
      system = {
        multilib = true;
        yama = "relaxed"; # For antichets
        lower-address-mmap = true;
      };
      network = {
        tcp-sack = true;
      };
      kernel = {
        zero-alloc = true;
        bdev-write-mount = true; # Disabling this breaks hibernation on swapfile
        binfmt-misc = true;
      };
      # debug.debugfs = true;
    };
    filesystems = {
      enable = true;
      normal = {
        "/var/log".options.bind = false;
        "/home".options = {
          bind = false;
          noexec = false;
        };
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
        # enableRemote = true;
      };
    };
  };

  # environment = {
  #   memoryAllocator.provider = "scudo";
  #   variables.SCUDO_OPTIONS = lib.mkDefault "zero_contents=false";
  # };
}
