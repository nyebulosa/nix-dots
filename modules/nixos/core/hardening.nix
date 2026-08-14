{
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  nix-mineral = {
    enable = true;
    preset = [
      "performance"
      "compatibility"
    ];
    settings = {
      system = {
        multilib = true;
      };
      network = {
        tcp-sack = true;
        log-martians = false;
      };
      kernel = {
        zero-alloc = false;
        io-uring = true;
        harden-bpf = false;
        strict-iommu = false;
        amd-iommu-force-isolation = false;
        iommu-passthrough = false;
        perf-subsystem.restrict-usage = false;
      };
      entropy = {
        hwrng = true;
      };
    };
    filesystems = {
      enable = false;
      normal = {
        "/var/log".options.bind = false;
        "/home".options.bind = false;
        "/tmp".options.noexec = false;
      };
    };
  };

  boot = {
    kernelParams = [ "init_on_alloc=1" ];
    kernel.sysctl = {
      "kernel.io_uring_disabled" = 1;
      "net.core.bpf_jit_harden" = 1;
    };
  };
  # boot = {
  #   kernelParams = [
  #     "slab_nomerge"
  #     "page_alloc.shuffle=1"
  #     "pti=off" # Fixes Meltdown but adds syscall overhead. AMD is not vulnerable.
  #     "randomize_kstack_offset=on"
  #     "vsyscall=none"
  #     "quiet"
  #     "loglevel=0"
  #     "init_on_alloc=1"
  #     "init_on_free=1" # Both init on alloc and on free have a performance toll. Very low tho. Init on free is heavier than on alloc. (they are complementary)
  #     "oops=panic"
  #     "debugfs=off" # Can break some management software, remove to test issues.
  #     "mitigations=auto"
  #   ];
  #   kernel.sysctl = {
  #     "kernel.kptr_restrict" = 2;
  #     "kernel.dmesg_restrict" = 1;
  #     "kernel.unprivileged_bpf_disabled" = 1;
  #     "net.core.bpf_jit_harden" = 2;
  #     "dev.tty.ldisc_autoload" = 0;
  #     "vm.unprivileged_userfaultfd" = 0;
  #     "kernel.kexec_load_disabled" = 1;
  #     "kernel.sysrq" = 4;
  #     "kernel.perf_event_paranoid" = 3;
  #     "kernel.yama.ptrace_scope" = 2; # Remove if debugging
  #     "vm.mmap_rnd_bits" = 32;
  #     "vm.mmap_rnd_compat_bits" = 16;
  #
  #     # Testing
  #     "vm.mmap_min_addr" = 32768;
  #     "fs.inotify.max_user_watches" = 524288;
  #
  #     # Network
  #     "net.ipv4.tcp_syncookies" = 1;
  #     "net.ipv4.tcp_rfc1337" = 1;
  #     "net.ipv4.conf.all.rp_filter" = 1;
  #     "net.ipv4.conf.default.rp_filter" = 1;
  #     "net.ipv4.conf.all.accept_redirects" = 0;
  #     "net.ipv4.conf.default.accept_redirects" = 0;
  #     "net.ipv4.conf.all.secure_redirects" = 0;
  #     "net.ipv4.conf.default.secure_redirects" = 0;
  #     "net.ipv6.conf.all.accept_redirects" = 0;
  #     "net.ipv6.conf.default.accept_redirects" = 0;
  #     "net.ipv4.conf.all.send_redirects" = 0;
  #     "net.ipv4.conf.default.send_redirects" = 0;
  #     "net.ipv4.conf.all.accept_source_route" = 0;
  #     "net.ipv4.conf.default.accept_source_route" = 0;
  #     "net.ipv6.conf.all.accept_source_route" = 0;
  #     "net.ipv6.conf.default.accept_source_route" = 0;
  #     # "net.ipv6.conf.all.use_tempaddr" = 2;
  #     # "net.ipv6.conf.default.use_tempaddr" = 2;
  #     # "net.ipv6.conf.all.accept_ra" = 0;
  #     # "net.ipv6.conf.default.accept_ra" = 0; # These last two can mess with ipv6, I don't use it anyways but I'm on a home network soo...
  #
  #     # Filesystem
  #     "fs.protected_symlinks" = 1;
  #     "fs.protected_hardlinks" = 1;
  #     "fs.protected_fifos" = 2;
  #     "fs.protected_regular" = 2;
  #   };
  # };
  security = {
    sudo.enable = lib.mkForce false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
      persistentAuth = {
        enable = true;
        enableRemote = true;
      };
    };
  };
  # environment = {
  #   memoryAllocator.provider = "scudo";
  #   variables.SCUDO_OPTIONS = lib.mkDefault "zero_contents=false";
  # };
}
