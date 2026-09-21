{
  pkgs,
  lib,
  inputs,
  ...
}:

{
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
    # udisks2.enable = true;
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
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
    gnome.gnome-keyring.enable = true;
    ratbagd.enable = true; # Required by piper
  };

  security = {
    rtkit.enable = true; # Required for pipewire
  };

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
    powertop
    brightnessctl
    xdg-utils
    distrobox
    ffmpeg
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
    proton-vpn
    protonplus
    scx-loader
    waypipe
    xdg-utils
    desktop-file-utils
  ];

  # Make apps run natively on Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    BROWSER = "/run/current-system/sw/bin/zen";
  };

  # State version
  system.stateVersion = "26.05"; # Do not change
}
