{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true; # This needs to be disabled if using lanzaboote
        consoleMode = "max";
        editor = false; # Better security
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    initrd.systemd.enable = lib.mkDefault true;
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
      "vm.dirty_background_bytes" = 134217728;
      "vm.dirty_writeback_centisecs" = 1500;
      "kernel.nmi_watchdog" = 0;
      "kernel.printk" = "3 3 3 3";
      "kernel.kptr_restrict" = 1;
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
      "fs.file-max" = 2097152;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3; # All my current machines are v3, can be changed per host
    kernelParams = [
      "zswap.enabled=0" # Don't have this with zram
      "split_lock_detect=off"
      "nowatchdog"
    ];
    tmp = {
      useTmpfs = true;
      #cleanOnBoot = true; # If not tmps then use this
    };
  };
}
