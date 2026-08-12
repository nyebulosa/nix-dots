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
        settings."global-dns-domain-*".servers = "1.1.1.1,1.0.0.1,9.9.9.9";
      };
      firewall.trustedInterfaces = [ "virbr0" ];
    };
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="ES"
    '';
    services = {
      resolved = {
        enable = true;
        settings.Resolve = {
          DNS = [
            "1.1.1.1#cloudflare-dns.com"
            "1.0.0.1#cloudflare-dns.com"
            "9.9.9.9#dns.quad9.net"
          ];
          FallbackDNS = [ ];
          Domains = [ "~." ];
          DNSOverTLS = "yes";
          DNSSEC = "yes";
        };
      };
    };
  };
}
