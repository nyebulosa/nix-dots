{
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  boot = {
    kernel = {
      sysctl = {
        "net.core.bpf_jit_harden" = 1;
      };
    };
  };

  nix-mineral = {
    enable = true;
    preset = [
      "compatibility"
      "performance"
    ];
    settings = {
      system = {
        multilib = true;
      };
      network = {
        tcp-sack = true;
        log-martians = false;
      };
      kernel = {
        iommu-passthrough = false;
        harden-bpf = false;
      };
      debug.debugfs = true;
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
