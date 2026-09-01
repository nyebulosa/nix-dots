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
  home = {
    username = "leonillo";
    homeDirectory = "/home/leonillo";
    packages = with pkgs; [
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
      (discord-ptb.override {
        withOpenASAR = true;
        withEquicord = true;
      })
      equibop
      orca-slicer
      easyeffects
      qbittorrent
      piper
      element-desktop
      signal-desktop
      zoom-us
      libreoffice-qt
      via
      obsidian

      # Dev
      rustup
      vscodium
      wayvr
      go
      nodejs
      python3
      claude-code
      pi-coding-agent
      opencode

      # Misc
      grim
      slurp
      dragon-drop # yazi's <C-n> drag-and-drop bind
      nwg-bar
      playerctl
      mako
      swaybg
      satty
      shared-mime-info
      file-roller
      xdg-user-dirs-gtk
    ];
  };

  # XDG User Directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # MIME Types
  xdg.mimeApps.associations.added = {
    "inode/directory" = [ "thunar.desktop" ];
  };

  services.swayidle =
    let
      # pgrep guard so idle + suspend don't stack two lockers
      lock = "${pkgs.procps}/bin/pgrep -x swaylock || ${config.programs.swaylock.package}/bin/swaylock -f";
      # Guarded on AC so a long build or download on mains isn't cut short
      sleep = "[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) = 0 ] && ${pkgs.systemd}/bin/systemctl suspend";
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
        {
          timeout = 1800;
          command = sleep;
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
      settings = {
        screenshots = true;
        effect-blur = "9x3";
        effect-vignette = "0.4:0.4";
        fade-in = 0.2;

        clock = true;
        timestr = "%H:%M";
        datestr = "%A, %d %B";

        indicator = true;
        indicator-radius = 110;
        indicator-thickness = 8;
        indicator-caps-lock = true;

        # rest of the palette comes from catppuccin.swaylock
        ring-color = lib.mkForce "cba6f7";
        inside-color = lib.mkForce "1e1e2ecc";
        inside-ver-color = lib.mkForce "1e1e2ecc";
        inside-clear-color = lib.mkForce "1e1e2ecc";
        inside-wrong-color = lib.mkForce "1e1e2ecc";
        inside-caps-lock-color = lib.mkForce "1e1e2ecc";
      };
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
        icon-theme = "Papirus-Dark";
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
          exec = "systemctl suspend-then-hibernate";
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
  };

  home.pointerCursor.enable = true;

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
