{
  ...
}:

{
  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 25;

        # Modules
        modules-left = [
          "niri/workspaces"
          "niri/window"
        ];
        modules-center = [ "custom/waybar-mpris" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "cpu"
          "temperature"
          "memory"
          "battery"
          "clock"
        ];

        # Module Configurations
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            # Nerd Font: filled circle (nf-fa-circle) / hollow circle (nf-fa-circle_o).
            # Swap for "\uf0c8" / "\uf096" to get squares instead.
            focused = "";
            active = "";
            urgent = "";
            default = "";
            empty = "";
          };
        };

        "niri/window" = {
          max-length = 40;
        };

        "tray" = {
          spacing = 10;
        };

        "clock" = {
          smooth-scrolling-threshold = 5;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M} ";
          format-alt = "{:%d-%m-%Y} ";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#cba6f7'><b>{}</b></span>";
              weekdays = "<span color='#a6adc8'><b>{}</b></span>";
              weeks = "<span color='#585b70'>{}</span>";
              days = "<span color='#cdd6f4'>{}</span>";
              today = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "cpu" = {
          interval = 2;
          format = "{usage}% {icon} ";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip = false;
          on-click = "kitty btop";
        };

        "memory" = {
          interval = 5;
          format = "{percentage}% {icon} ";
          format-icons = [
            "󰪞"
            "󰪟"
            "󰪠"
            "󰪡"
            "󰪢"
            "󰪣"
            "󰪤"
            "󰪥"
          ];
          states = {
            warning = 80;
            critical = 92;
          };
          on-click = "kitty btop";
        };

        "temperature" = {
          # k10temp. AMD Zen fixes the Data Fabric at 00:18.3, so this path is
          # stable across reboots and identical on both hosts, unlike hwmon<N>
          # numbering (on goingmerry hwmon3 is cros_ec, an EC board sensor).
          hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
          input-filename = "temp1_input";
          interval = 2;
          warning-threshold = 70;
          critical-threshold = 80;
          format = "{temperatureC}°{icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "battery" = {
          interval = 10;
          events = {
            on-discharging-warning = "notify-send -u normal 'Battery low' 'Under 20% left'";
            on-discharging-critical = "notify-send -u critical 'Battery critical' 'Plug in now'";
          };
          states = {
            good = 95;
            warning = 20;
            critical = 10;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰃨";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "network" = {
          # Netlink events don't fire on signal changes, so poll for them.
          interval = 5;
          format-wifi = "{icon}";
          format-icons = [
            "󰤭"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{essid}  {signalStrength}%  ({ipaddr})";
          tooltip-format-ethernet = "{ifname}  {ipaddr}";
          on-click = "kitty nmtui";
        };

        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = "󰆪 {icon} {format_source}";
          format-muted = "󰆪 {format_source}";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󰂑";
            headset = "󰂑";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          scroll-step = 5;
          smooth-scrolling-threshold = 4;
          max-volume = 120;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        "custom/waybar-mpris" = {
          return-type = "json";
          exec = ''
            waybar-mpris --position --autofocus --order "SYMBOL:ARTIST:TITLE:POSITION" \
              --play " :( " --pause " :3 "
          '';
          on-click = "waybar-mpris --send toggle";
          on-click-right = "waybar-mpris --send toggle";
          on-scroll-up = "waybar-mpris --send next";
          on-scroll-down = "waybar-mpris --send prev";
          smooth-scrolling-threshold = 12;
          escape = true;
          max-length = 48;
        };
      };
    };

    # Style Configuration (CSS)
    style = ''
      * {
        font-family: "Geist", "Geist Mono", "Symbols Nerd Font";
        font-size: 14px;
        font-weight: 700;
      }

      @define-color base   #1e1e2e;
      @define-color mantle #181825;
      @define-color crust  #11111b;

      @define-color text     #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color subtext1 #bac2de;

      @define-color surface0 alpha(#313244, 0.0);
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;

      @define-color overlay0 #6c7086;
      @define-color overlay1 #7f849c;
      @define-color overlay2 #9399b2;

      @define-color blue      #89b4fa;
      @define-color lavender  #b4befe;
      @define-color sapphire  #74c7ec;
      @define-color sky       #89dceb;
      @define-color teal      #94e2d5;
      @define-color green     #a6e3a1;
      @define-color yellow    #f9e2af;
      @define-color peach     #fab387;
      @define-color maroon    #eba0ac;
      @define-color red       #f38ba8;
      @define-color mauve     #cba6f7;
      @define-color pink      #f5c2e7;
      @define-color flamingo  #f2cdcd;
      @define-color rosewater #f5e0dc;

      /* Matches home/kitty.nix: background = "#1e1e2e" (@base) at
         background_opacity = "0.9". */
      window#waybar {
        background-color: alpha(@base, 0.9);
        color: @text;
      }

      #workspaces,
      #window,
      #tray,
      #pulseaudio,
      #network,
      #cpu,
      #temperature,
      #memory,
      #battery,
      #clock,
      #custom-waybar-mpris {
        padding: 0 10px;
      }

      #workspaces button {
        padding: 0 6px;
        margin: 0;
        min-height: 0;
        color: @overlay0;
        background: transparent;
        border: none;
        box-shadow: none;
      }

      #workspaces button.empty {
        color: @surface1;
      }

      #workspaces button.focused,
      #workspaces button.active {
        color: @mauve;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #workspaces button:hover {
        background: transparent;
        box-shadow: none;
        color: @lavender;
      }

      /* Catppuccin hue sweep across the bar, left to right:
         rosewater -> pink -> mauve -> lavender -> blue -> sapphire
         -> sky -> teal -> green. */
      #window {
        color: @rosewater;
      }

      #custom-waybar-mpris {
        color: @pink;
      }

      #pulseaudio {
        color: @mauve;
      }

      #network {
        color: @lavender;
      }

      #cpu {
        color: @blue;
      }

      #temperature {
        color: @sapphire;
      }

      #memory {
        color: @sky;
      }

      #battery {
        color: @teal;
      }

      #clock {
        color: @green;
      }

      /* Alert states override the gradient, so they stay readable. */
      #cpu.critical,
      #memory.critical,
      #temperature.critical,
      #battery.critical:not(.charging) {
        color: @red;
      }

      #cpu.warning,
      #memory.warning,
      #temperature.warning,
      #battery.warning:not(.charging) {
        color: @peach;
      }

      #battery.charging {
        color: @green;
      }

      #network.disconnected,
      #pulseaudio.muted {
        color: @overlay0;
      }

      /* Without these, tooltips (e.g. the clock's calendar) fall through to the
         default GTK theme and render light-on-light against the bar. */
      tooltip {
        background-color: alpha(@base, 0.95);
        border: 1px solid @surface1;
        border-radius: 8px;
      }

      tooltip label {
        color: @text;
        padding: 6px;
      }
    '';
  };
}
