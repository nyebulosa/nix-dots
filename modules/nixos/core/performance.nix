{
  ...
}:

{
  boot = {
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
      "vm.dirty_bytes" = 536870912;
      "vm.dirty_background_bytes" = 268435456;
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
    blacklistedKernelModules = [ "sp5100_tco" ];
  };
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    priority = 100;
    algorithm = "zstd";
  };
  services = {
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none"
      ACTION=="add|change", KERNEL=="sd[a-z]|xvd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]|xvd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      SUBSYSTEM=="misc", KERNEL=="cpu_dma_latency", GROUP="audio", MODE="0660"
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
  };
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    "w /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 0"
  ];
}
