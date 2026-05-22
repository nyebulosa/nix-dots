{
  config,
  lib,
  pkgs,
  ...
}:

{
  systemd = {
    services = {
      "user@".serviceConfig.Delegate = "cpu cpuset io memory pids";
      systemd-udev-settle.enable = false; # Reduces boot time
      mullvad-daemon = {
        after = lib.mkForce [ "network.target" ];
        wants = lib.mkForce [ ];
      };
    };
    settings.Manager = {
      DefaultTimeoutStartSec = "15s";
      DefaultTimeoutStopSec = "10s";
      DefaultLimitNOFILE = "2048:2097152";
    };
    user.extraConfig = ''
      DefaultLimitNOFILE=1024:1048576
    '';
    tmpfiles.rules = [
      "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
      "w /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 0"
    ];
  };
  services.udev = {
    extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="cpu_dma_latency", GROUP="audio", MODE="0660"
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
    packages = with pkgs; [
      via
      vial
      qmk-udev-rules
      arrpc # For discord
    ];
  };
  # Fixes run0
  security.pam.services.systemd-user = {
    setEnvironment = true;
    pamMount = false;
  };
}
