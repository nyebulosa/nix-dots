{ lib, ... }:

{
  security = {
    polkit = {
      enable = lib.mkDefault true;
      # Paired with security.run0.persistentAuth in hardening.nix
      settings.Polkitd.ExpirationSeconds = lib.mkDefault 120;
    };
    soteria.enable = lib.mkDefault true;
  };
}
