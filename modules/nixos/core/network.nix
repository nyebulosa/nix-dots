{
  config,
  lib,
  pkgs,
  ...
}:

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
        ethernet.macAddress = "stable"; # Set this to random if you want it to change every time, might break sum stuff tho.
        wifi.backend = lib.mkIf cfg.wifi.enable "iwd";
        dns = "systemd-resolved";
        logLevel = "WARN";
        settings = {
          "global-dns-domain-*".servers = "1.1.1.1,1.0.0.1,9.9.9.9";
          connectivity.enabled = false; # ima jst do this myself
        };
      };
      modemmanager.enable = false; # i don't use ts bruh
      firewall.trustedInterfaces = [ "virbr0" ];
    };

    systemd.services.NetworkManager.serviceConfig = {
      # a bit of hardening never hurts i guess
      ProtectHome = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
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
    environment.systemPackages = with pkgs; lib.mkIf cfg.wifi.enable [ impala ];
  };
}
