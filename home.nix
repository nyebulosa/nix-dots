{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Import Modules
  imports = [
    home/waybar.nix
    home/kitty.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # User Information
  home.username = "leonillo";
  home.homeDirectory = "/home/leonillo";

  # Packages
  home.packages = with pkgs; [
    # CLI
    gh
    yt-dlp
    fastfetch
    pamixer
    wl-clipboard
    cliphist
    hyfetch

    # GUI
    filezilla
    pavucontrol
    qpwgraph
    oculante
    mpv
    gimp-with-plugins
    anydesk
    bottles
    librewolf
    waypaper
    kdePackages.filelight
    (discord.override {
      withOpenASAR = true;
      # withVencord = true;
      withEquicord = true;
    })
    equibop
    orca-slicer
    easyeffects
    qbittorrent
    lmstudio
    piper
    element-desktop
    fluffychat
    signal-desktop
    zoom-us
    libreoffice-qt
    via
    obsidian

    # Gaming
    parsec-bin
    #heroic
    (prismlauncher.override {
      jdks = [
        temurin-jre-bin-8
        temurin-jre-bin-25
        temurin-jre-bin
        zulu25
        # semeru-bin
        # graalvmPackages.graalvm-oracle_25
      ];
      additionalPrograms = [ vlc ];
      additionalLibs = [
        vlc
        opencl-headers
        ocl-icd
      ];
    })
    r2modman
    bs-manager

    # Dev
    rustup
    vscodium
    wayvr
    jetbrains.idea
    go
    nodejs
    python3
    claude-code
    pi-coding-agent
    opencode

    # Misc
    grim
    slurp
    nwg-bar
    playerctl
    mako
    swaybg
    waybar-mpris
    satty
    shared-mime-info
    file-roller
  ];

  # XDG User Directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # MIME Types
  xdg.mimeApps.associations.added = {
    "inode/directory" = [ "nemo.desktop" ];
  };

  services.arrpc = {
    enable = true;
    package = pkgs.arrpc; # Default
    systemdTarget = "graphical-session.target"; # Default
  };

  services.swayidle =
    let
      # pgrep guard so idle + suspend don't stack two lockers
      lock = "${pkgs.procps}/bin/pgrep -x swaylock || ${config.programs.swaylock.package}/bin/swaylock -f";
    in
    {
      enable = true;
      events = {
        "before-sleep" = lock;
        "lock" = lock;
      };
      timeouts = [
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 360;
          command = "/run/current-system/sw/bin/niri msg action power-off-monitors";
        }
      ];
    };

  # Programs
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      plugins = [
        #{ name = "tide"; src = pkgs.fishPlugins.tide.src; }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
    };

    btop.enable = true;

    home-manager.enable = true; # probably don't want to remove this :3

    yazi = {
      enable = true;
      enableFishIntegration = true;
      keymap = {
        mgr.prepend_keymap = [
          {
            run = "plugin mount";
            on = [ "M" ];
          }
          {
            on = [ "<C-n>" ];
            run = ''shell -- dragon-drop -x -i -T "$0"'';
          }
        ];
      };
      settings = {
        mgr = {
          show_hidden = true;
          show_symlink = true;
        };
        plugins.prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
      };
      plugins = {
        git = pkgs.yaziPlugins.git;
        mount = pkgs.yaziPlugins.mount;
      };
      initLua = ''require("git"):setup()'';
    };
    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
    };
    rofi = {
      enable = true;
      modes = [
        "drun"
        "window"
        "emoji"
        {
          name = "clipboard";
          path = "cliphist-rofi-img";
        }
      ];
      extraConfig = {
        icon-theme = "ePapirus-dark";
        show-icons = true;
        terminal = "kitty";
        drun-display-format = "{icon} | {name}";
        location = 0;
        disable-history = false;
        hide-scrollbar = true;
        display-drun = " 󰀻  Apps ";
        display-clipboard = " 󰅇  Clip ";
        display-window = "   Win";
        display-emoji = " 󰞅 Emoji ";

        sidebar-mode = true;
      };
      plugins = with pkgs; [
        rofi-emoji
      ];
      theme = "catppuccin-mocha";
    };

    spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
      in
      {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          shuffle
          loopyLoop
        ];
        enabledCustomApps = with spicePkgs.apps; [
          marketplace
          lyricsPlus
          newReleases
          ncsVisualizer
        ];
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
        windowManagerPatch = true;
      };
  };

  home.shell.enableFishIntegration = true;

  # File Configurations
  home.file = {
    "./.config/nwg-bar" = {
      source = ./home/nwg-bar;
      recursive = true;
    };
    # generated so the icons resolve to the store instead of /usr/share
    "./.config/nwg-bar/bar.json".text =
      let
        icon = name: "${pkgs.nwg-bar}/share/nwg-bar/images/${name}.svg";
      in
      builtins.toJSON [
        {
          label = "Lock";
          exec = "${config.programs.swaylock.package}/bin/swaylock -f";
          icon = icon "system-lock-screen";
        }
        {
          label = "Suspend";
          exec = "systemctl suspend";
          icon = icon "system-suspend";
        }
        {
          label = "Reboot";
          exec = "systemctl reboot";
          icon = icon "system-reboot";
        }
        {
          label = "Shutdown";
          exec = "systemctl -i poweroff";
          icon = icon "system-shutdown";
        }
      ];
    "./.config/mako" = {
      source = ./home/mako;
      recursive = true;
    };
    "./.config/rofi/cliphist-rofi-img".source = ./home/rofi/cliphist-rofi-img;
    "./.local/share/rofi/themes" = {
      source = ./home/rofi-theme;
      recursive = true;
    };
    "./.config/hypr/replay" = {
      source = ./home/hypr/replay;
      recursive = true;
    };
    # "./.config/hypr/hyprlock.conf".source = ./home/hypr/hyprlock.conf;
    # "./.config/xdg-desktop-portal/hyprland-portals.conf".source = ./home/hypr/hyprland-portals.conf;
    # "./.config/hypr/xdph.conf".source = ./home/hypr/xdph.conf;
    "./.config/niri/config.kdl".source = ./home/niri.kdl;
  };

  # Catppuccin Theme Configuration
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
    cursors = {
      enable = true;
      accent = "dark";
      flavor = "mocha";
    };
    kvantum = {
      enable = false;
      apply = false;
    };
    vivaldi.enable = false;
    waybar.enable = false;
    rofi.enable = false;
    kitty.enable = false;
  };

  stylix = {
    targets = {
      waybar.enable = false;
      btop.enable = false;
      kitty.enable = true;
      yazi.enable = false;
      vencord.enable = false;
      swaylock.enable = false;
      rofi.enable = false;
      spicetify.enable = false;
    };
  };

  gtk = {
    enable = true;
    colorScheme = lib.mkForce "dark";
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = lib.mkForce "prefer-dark";

  # Session Variables
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # State Version
  home.stateVersion = "26.05"; # Don't change this
}
