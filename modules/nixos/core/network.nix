{ config, lib, ... }:

let
  cfg = config.my.network;
in
{
  options.my.network = {
    wifi = {
      enable = lib.mkEnableOption "wifi" // {
        default = false;
      };
    };
  };
  config = {
    networking = {
      wireless.iwd = {
        enable = cfg.wifi.enable;
        settings.General.AddressRandomization = "network";
      };
      networkmanager = {
        enable = true;
        wifi.backend = lib.mkIf cfg.wifi.enable "iwd";
      };
      firewall.trustedInterfaces = [ "virbr0" ];
    };
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="ES"
    '';
  };
}
