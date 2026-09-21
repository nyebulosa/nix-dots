{
  config,
  lib,
  pkgs,
  ...
}:

# Might turn this entire module into a way to easily add other users idk.
# Don't have any friends- sorry i meant don't have any other users to add rn
# so no point right now anyways.

let
  cfg = config.my.user;
in
{
  options.my.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "nebula";
      description = "Login name of the primary user. Everything else derives from this.";
    };
  };

  config = {
    users = {
      mutableUsers = false;
      users = {
        ${cfg.name} = {
          isNormalUser = true;
          shell = pkgs.fish;
          description = "Nebula";
          hashedPasswordFile = "/persist/passwords/${cfg.name}";
          extraGroups = [
            "wheel"
            "video"
            "podman"
            "libvirtd"
            "networkmanager"
          ];
        };
        root.hashedPasswordFile = "/persist/passwords/root";
      };
    };
  };
}
