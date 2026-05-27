{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  catppuccin = {
    enable = true;
    accent = "mauve";
    flavor = "mocha";
  };

  programs = {
    gpu-screen-recorder.enable = true; # Required for screen recording
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-vcs-plugin
        thunar-media-tags-plugin
      ];
    };
    fish.enable = true;
    htop.enable = true;
    git.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    };
    java = {
      enable = true;
      package = pkgs.temurin-bin-25;
    };
    virt-manager.enable = true; # QEMU/KVM
    yazi = {
      enable = true;
    };
    zoxide.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    starship = {
      enable = true;
    };
  };
  virtualisation = {
    libvirtd = {
      enable = true; # Enable libvirt daemon
      qemu = {
        swtpm.enable = true;
      };
    };
  };
  #virtualisation.waydroid.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Hardware and power management
  hardware = {
    enableAllFirmware = true;
    wirelessRegulatoryDatabase = true; # Required for framework laptop
  };
  #powerManagement.powertop.enable = true; # Enable powertop
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    priority = 100;
    algorithm = "zstd"; # Better performance/compression ratio
  };

  networking = {
    wireless.iwd = {
      enable = true;
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    firewall.trustedInterfaces = [ "virbr0" ]; # Fixes libvirt networking
  };
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="ES"
  '';

  services = {
    tlp.enable = lib.mkForce false;
    ratbagd.enable = true;
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
    };
    tumbler.enable = true;
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";
        fallbackDns = [
          "9.9.9.9#dns.quad9.net"
          "1.1.1.1#cloudflare-dns.com"
        ];
      };
    };
    udisks2.enable = true;
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      # Low-latency config (CachyOS defaults to lower quantum than stock)
      # Temporarily commented while this gets revamped and modularized, don't want audio cracks and shi on my laptop
      # extraConfig.pipewire = {
      #   "99-low-latency" = {
      #     context.properties = {
      #       default.clock = {
      #         rate = 48000;
      #         quantum = 64; # CachyOS uses 64; stock is 1024
      #         min-quantum = 32;
      #         max-quantum = 8192;
      #       };
      #     };
      #   };
      # };
    };
    flatpak.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
    };
    xserver = {
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };
    openssh = {
      enable = true;
      # openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "leonillo" ];
      };
    };
    gnome.gnome-keyring.enable = true;
    # ollama = {
    #   enable = true;
    #   package = pkgs.ollama-rocm;
    # };
  };

  security = {
    rtkit.enable = true; # Required for pipewire
    polkit.enable = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.symbols-only
      font-awesome
      meslo-lgs-nf
      noto-fonts
      noto-fonts-color-emoji
      nanum # Orca slicer crashes without ts it seems
    ];
    enableDefaultPackages = true;
    # fontconfig = {
    #   antialias = true;
    #   cache32Bit = true;
    #   hinting = {
    #     enable = true;
    #     #autohint = true;
    #   };
    #   subpixel = {
    #     rgba = "rgb";
    #     lcdfilter = "default";
    #   };
    # };
  };

  # Locale related settings
  time.timeZone = "Europe/Madrid";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  console.keyMap = "colemak"; # Keymap outside X

  users.users.leonillo = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "leoNillo";
    extraGroups = [
      "wheel"
      "libvirtd"
      "games"
      "video"
      "gamemode"
      "docker"
      "render"
      "audio"
      "input"
      "networkmanager"
    ];
    initialHashedPassword = "$y$j9T$ReVR1vqESFLY8Y7dkJDb/.$7piDB7IUbIgbm/16XbzfnehT.bPFy4m7RZADZSysmz0"; # Default password on install, must be changed later
  };

  # System packages, installed globally
  environment.systemPackages = with pkgs; [
    wget
    curl
    btop
    htop
    zip
    unzip
    p7zip
    unrar
    lm_sensors
    gcc
    libnotify
    killall
    lzip
    # linux-firmware
    powertop
    pulseaudio
    brightnessctl
    gpu-screen-recorder
    lsfg-vk
    lsfg-vk-ui
    impala
    nix-index
    fzf
    ffmpegthumbnailer
    webp-pixbuf-loader
    gdk-pixbuf
    waypipe
    xdg-utils
    glib
    distrobox
    arrpc
    #inputs.affinity-nix.packages.x86_64-linux.v3
    ffmpeg
    lazygit
    nixfmt
    statix
    sbctl
    # swtpm
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };

  # Make apps run natively on Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  hardware.cpu.amd.updateMicrocode = true;

  # State version
  system.stateVersion = "26.05"; # Do not change
}
