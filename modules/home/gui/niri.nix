{ ... }:

{
  wayland.windowManager.niri = {
    # programs.niri (modules/nixos/features/niri.nix) already ships the session,
    # its systemd units, the portal and xwayland-satellite system-wide
    systemd.enable = false;
    portalPackage = null;
    xwaylandSatellitePackage = null;

    enable = true;

    settings = {
      input = {
        keyboard.numlock = { };
        touchpad = {
          tap = { };
          disabled-on-external-mouse = { };
        };
        mouse.accel-profile = "flat";
      };

      layout = {
        gaps = 6;
        center-focused-column = "never";

        preset-column-widths._children = [
          { proportion = 0.2; }
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 0.8; }
        ];
        default-column-width.proportion = 0.5;

        focus-ring = {
          off = { };
          width = 2;
          inactive-color = "#313244";
          active-gradient._props = {
            from = "#cba6f7";
            to = "#89b4fa";
            angle = 45;
            relative-to = "workspace-view";
            "in" = "srgb-linear";
          };
        };

        border = {
          width = 1;
          active-color = "#cba6f7";
          inactive-color = "#9399b2";
          urgent-color = "#f38ba8";
        };

        shadow = {
          on = { };
          draw-behind-window = true;
          softness = 40;
          spread = 5;
          offset._props = {
            x = 0;
            y = 0;
          };
          color = "#00000064";
          inactive-color = "#00000064";
        };
      };

      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      hotkey-overlay.skip-at-startup = { };
      overview.backdrop-color = "#11111b";

      # The per-surface `background-effect { blur true }` rules below only toggle
      # blur on; the look is tuned here. There is no radius/size setting -- blur
      # width comes from `passes` (dual-kawase), and each pass costs GPU time,
      # which matters on goingmerry. `noise` dithers the result to hide banding
      # on flat gradients.
      blur = {
        passes = 3;
        noise = 0.03;
        saturation = 1.1;
      };

      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = { };

        "Mod+T" = {
          _props.hotkey-overlay-title = "Open a Terminal: kitty";
          spawn = [ "kitty" ];
        };
        "Mod+D" = {
          _props.hotkey-overlay-title = "Run an Application: rofi";
          spawn = [
            "rofi"
            "-show"
            "drun"
          ];
        };
        "KP_9" = {
          _props.hotkey-overlay-title = "Run an Application: rofi";
          spawn = [
            "rofi"
            "-show"
            "drun"
          ];
        };
        "Super+Alt+L" = {
          _props.hotkey-overlay-title = "Lock the Screen: swaylock";
          spawn = [ "swaylock" ];
        };
        "Super+Alt+P" = {
          _props.hotkey-overlay-title = "Power Menu: nwg-bar";
          spawn = [ "nwg-bar" ];
        };
        "Super+Alt+S" = {
          _props = {
            allow-when-locked = true;
            hotkey-overlay-title = null;
          };
          spawn-sh = "pkill orca || exec orca";
        };

        "XF86AudioRaiseVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
        };
        "XF86AudioLowerVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        };
        "XF86AudioMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        "XF86AudioPlay" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl play-pause";
        };
        "XF86AudioStop" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl stop";
        };
        "XF86AudioPrev" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl previous";
        };
        "XF86AudioNext" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl next";
        };

        "XF86MonBrightnessUp" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "set"
            "+5%"
          ];
        };
        "XF86MonBrightnessDown" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "set"
            "5%-"
          ];
        };

        "Mod+X".spawn = [ "thunar" ];
        "Mod+Shift+X".spawn = [ "nemo" ];
        "Mod+W".spawn = [
          "rofi"
          "-show"
          "window"
        ];
        "Mod+V".spawn = [
          "rofi"
          "-show"
          "clipboard"
        ];
        "Mod+G".spawn-sh = "bash ~/.config/hypr/replay/save.sh";
        "Mod+Shift+G".spawn-sh = "nwg-bar -t ~/.config/hypr/replay/nwg-bar/bar.json";

        "Mod+L" = {
          _props.repeat = false;
          toggle-overview = { };
        };
        "Mod+Q" = {
          _props.repeat = false;
          close-window = { };
        };

        "Mod+Left".focus-column-left = { };
        "Mod+Down".focus-window-down = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Right".focus-column-right = { };
        "Mod+N".focus-column-left = { };
        "Mod+E".focus-window-down = { };
        "Mod+I".focus-window-up = { };
        "Mod+O".focus-column-right = { };

        "Mod+Ctrl+Left".move-column-left = { };
        "Mod+Ctrl+Down".move-window-down = { };
        "Mod+Ctrl+Up".move-window-up = { };
        "Mod+Ctrl+Right".move-column-right = { };
        "Mod+Ctrl+N".move-column-left = { };
        "Mod+Ctrl+E".move-window-down = { };
        "Mod+Ctrl+I".move-window-up = { };
        "Mod+Ctrl+O".move-column-right = { };

        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };
        "Mod+Ctrl+Home".move-column-to-first = { };
        "Mod+Ctrl+End".move-column-to-last = { };

        "Mod+Shift+Left".focus-monitor-left = { };
        "Mod+Shift+Down".focus-monitor-down = { };
        "Mod+Shift+Up".focus-monitor-up = { };
        "Mod+Shift+Right".focus-monitor-right = { };
        "Mod+Shift+N".focus-monitor-left = { };
        "Mod+Shift+E".focus-monitor-down = { };
        "Mod+Shift+I".focus-monitor-up = { };
        "Mod+Shift+O".focus-monitor-right = { };

        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
        "Mod+Shift+Ctrl+N".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+E".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+I".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+O".move-column-to-monitor-right = { };

        "Mod+Page_Down".focus-workspace-down = { };
        "Mod+Page_Up".focus-workspace-up = { };
        "Mod+U".focus-workspace-down = { };
        "Mod+Y".focus-workspace-up = { };
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };
        "Mod+Ctrl+U".move-column-to-workspace-down = { };
        "Mod+Ctrl+Y".move-column-to-workspace-up = { };

        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Shift+U".move-workspace-down = { };
        "Mod+Shift+Y".move-workspace-up = { };

        "Mod+WheelScrollDown" = {
          _props.cooldown-ms = 100;
          focus-workspace-down = { };
        };
        "Mod+WheelScrollUp" = {
          _props.cooldown-ms = 100;
          focus-workspace-up = { };
        };
        "Mod+Ctrl+WheelScrollDown" = {
          _props.cooldown-ms = 100;
          move-column-to-workspace-down = { };
        };
        "Mod+Ctrl+WheelScrollUp" = {
          _props.cooldown-ms = 100;
          move-column-to-workspace-up = { };
        };

        "Mod+WheelScrollRight".focus-column-right = { };
        "Mod+WheelScrollLeft".focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".move-column-left = { };

        "Mod+Shift+WheelScrollDown".focus-column-right = { };
        "Mod+Shift+WheelScrollUp".focus-column-left = { };
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };

        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-column-width-back = { };
        "Mod+Ctrl+Shift+R".switch-preset-window-height = { };
        "Mod+Ctrl+R".reset-window-height = { };

        "Mod+F".maximize-column = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+M".maximize-window-to-edges = { };
        "Mod+Ctrl+F".expand-column-to-available-width = { };
        "Mod+Ctrl+Shift+F".toggle-windowed-fullscreen = { };

        "Mod+C".center-column = { };
        "Mod+Ctrl+C".center-visible-columns = { };

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+Space".toggle-window-floating = { };
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };
        "Mod+Shift+T".toggle-column-tabbed-display = { };

        "Print".screenshot = { };
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window = { };

        "Mod+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = { };
        };

        "Mod+Shift+P".power-off-monitors = { };
        "Mod+Shift+Ctrl+Q".quit = { };
        "Ctrl+Alt+Delete".quit = { };
      };

      _children = [
        {
          output = {
            _args = [ "eDP-1" ];
            mode = "2256x1504@59.999";
            scale = 1.3333333;
          };
        }
        # {
        #   output = {
        #     _args = [ "DP-3" ];
        #     mode = "2560x1440";
        #     scale = 1;
        #     transform = "normal";
        #     position._props = {
        #       x = 0;
        #       y = 0;
        #     };
        #     variable-refresh-rate = { };
        #   };
        # }
        # {
        #   output = {
        #     _args = [ "DP-2" ];
        #     mode = "1920x1080";
        #     scale = 1;
        #     transform = "270";
        #     position._props = {
        #       x = 2560;
        #       y = -240;
        #     };
        #     layout.default-column-width.proportion = 1.0;
        #   };
        # }

        { spawn-at-startup = [ "waybar" ]; }
        {
          spawn-at-startup = [
            "steam"
            "-silent"
          ];
        }
        {
          spawn-at-startup = [
            "waypaper"
            "--restore"
          ];
        }
        { spawn-at-startup = [ "soteria" ]; }
        { spawn-sh-at-startup = "wl-paste --type text --watch cliphist store"; }
        { spawn-sh-at-startup = "wl-paste --type image --watch cliphist store"; }

        # Work around WezTerm's initial configure bug by setting an empty
        # default-column-width
        {
          window-rule = {
            match._props.app-id = ''^org\.wezfurlong\.wezterm$'';
            default-column-width = { };
          };
        }
        {
          window-rule = {
            match._props.app-id = "^kitty$";
            default-column-width = { };
          };
        }

        { window-rule.background-effect.blur = true; }
        # Blur behind waybar, same as windows get above
        {
          layer-rule = {
            match._props.namespace = "^waybar$";
            background-effect.blur = true;
          };
        }

        {
          window-rule = {
            match._props = {
              app-id = "steam";
              title = ''^notificationtoasts_\d+_desktop$'';
            };
            default-floating-position._props = {
              x = 10;
              y = 10;
              relative-to = "bottom-right";
            };
          };
        }
        # Matches both host Firefox and the Flatpak
        {
          window-rule = {
            match._props.title = "^Picture-in-Picture$";
            open-floating = true;
          };
        }

        {
          window-rule = {
            geometry-corner-radius = 5;
            clip-to-geometry = true;
          };
        }

        {
          window-rule = {
            variable-refresh-rate = true;
            _children = [
              { match._props.app-id = "gamescope"; }
              { match._props.title = "Minecraft"; }
              { match._props.app-id = "steam_app_"; }
              { match._props.title = "Lethal Company"; }
            ];
          };
        }
      ];
    };
  };
}
