{
  config,
  lib,
  pkgs,
  ...
}:

let
  laptop = config.my.power.laptop;
  alpmPolicy = if laptop then "med_power_with_dipm" else "max_performance";
in
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3; # All my current machines are v3, can be changed per host
    kernel.sysctl = {
      # Based on Valve's platform optimizations and cachyos optimizations
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "net.ipv4.tcp_fin_timeout" = 5;
      "vm.max_map_count" = 2147483642;
      "vm.swappiness" = 150;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "kernel.nmi_watchdog" = 0;
      "kernel.printk" = "3 3 3 3";
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
      "fs.file-max" = 2097152;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelParams = [
      "zswap.enabled=0" # ZRAM Conflict
      "split_lock_detect=off"
      "nowatchdog"
    ];
    kernelModules = [ "ntsync" ];
    blacklistedKernelModules = [
      "sp5100_tco"
      "iTCO_wdt"
    ];
    extraModprobeConfig = "options snd_hda_intel power_save=${if laptop then "10" else "0"}";
  };
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
    algorithm = "zstd";
  };
  services = {
    # ananicy = {
    #   enable = true;
    #   package = pkgs.ananicy-cpp;
    #   rulesProvider = pkgs.ananicy-rules-cachyos;
    #   # settings.cgroup_realtime_workaround = lib.mkForce false;
    # };
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
      ACTION=="add|change", KERNEL=="sd[a-z]*|xvd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]*|xvd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_supported}=="1", ATTR{link_power_management_policy}="${alpmPolicy}"
      SUBSYSTEM=="misc", KERNEL=="cpu_dma_latency", GROUP="audio", MODE="0660"
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    ''
    + lib.optionalString laptop ''
      SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", RUN+="${pkgs.runtimeShell} -c 'echo 10 > /sys/module/snd_hda_intel/parameters/power_save'"
      SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", RUN+="${pkgs.runtimeShell} -c 'echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"
    '';
  };
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    "w /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
  ];
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "@audio";
      type = "-";
      item = "nice";
      value = "-11";
    }
  ];
}
