{
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

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
      sudo-shim.enable = true;
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
