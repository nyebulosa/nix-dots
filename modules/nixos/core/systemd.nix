_:

{
  systemd = {
    services = {
      systemd-udev-settle.enable = false; # Reduces boot time
    };
    settings.Manager = {
      DefaultTimeoutStartSec = "15s";
      DefaultTimeoutStopSec = "10s";
      DefaultLimitNOFILE = "2048:2097152";
    };
    user.settings.Manager = {
      DefaultLimitNOFILE = "1024:1048576";
    };
  };
}
