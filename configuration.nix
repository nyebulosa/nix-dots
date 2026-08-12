{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "mauve";
    flavor = "mocha";
    plymouth.enable = false;
    tty.enable = false; # Emits 32 vt.default_* colours, the kernel takes 16
  };

  programs = {
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
    # git.enable = true;
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
    virt-manager.enable = true;
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
    nix-index.enable = true;
  };
  #virtualisation.waydroid.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  services = {
    tlp.enable = lib.mkForce false;
    # ratbagd.enable = true;
    mullvad-vpn = {
      enable = true;
      gui.enable = true;
    };
    tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
    };
    tumbler.enable = true;
    timesyncd.enable = false;
    chrony = {
      enable = true;
      enableNTS = true;
      servers = [
        "time.cloudflare.com"
        "nts.netnod.se"
        "ptbtime1.ptb.de"
      ];
    };
    journald.extraConfig = ''
      SystemMaxUse=500M
      SystemMaxFileSize=50M
    '';
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
    openssh.enable = false; # Tailscale has it's own
    gnome.gnome-keyring.enable = true;
    speechd.enable = false;
    ratbagd.enable = true; # Required by piper
    # ollama = {
    #   enable = true;
    #   package = pkgs.ollama-rocm;
    # };
  };

  security = {
    rtkit.enable = true; # Required for pipewire
    pam.services = {
      sddm.enableGnomeKeyring = true;
      swaylock.rules.auth.fprintd.control = lib.mkForce "required";
    };
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

  users = {
    mutableUsers = false;
    users = {
      leonillo = {
        isNormalUser = true;
        shell = pkgs.fish;
        description = "leoNillo";
        hashedPasswordFile = "/persist/passwords/leonillo";
        extraGroups = [
          "wheel"
          "video"
          "podman"
          "libvirtd"
          "render"
          "audio"
          "input"
          "uinput"
          "networkmanager"
        ];
      };
      root.hashedPasswordFile = "/persist/passwords/root";
    };
  };

  # System packages, installed globally
  environment.systemPackages = with pkgs; [
    wget
    curl
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
    impala
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
    git
    nixfmt
    statix
    sbctl
    swtpm
    comma
    nil
    ripgrep
    imagemagick
    fd
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    libdisplay-info
    fq
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      kmscon.enable = false;
      plymouth.enable = false;
      console.enable = true; # Themes the tty via console.colors instead
    };
  };

  # Make apps run natively on Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # State version
  system.stateVersion = "26.05"; # Do not change
}
