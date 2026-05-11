{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 18;

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
          on-click = "activate";
          format-icons = {
            "1" = "α";
            "2" = "β";
            "3" = "γ";
            "4" = "δ";
            "5" = "ε";
            "6" = "ζ";
            "7" = "η";
            "8" = "θ";
            "9" = "ι";
          };
        };

        "tray" = {
          spacing = 10;
        };

        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M} ";
          format-alt = "{:%d-%m-%Y} ";
        };

        "cpu" = {
          format = "{usage}% ";
          tooltip = false;
        };

        "memory" = {
          format = "{}% ";
        };

        "temperature" = {
          thermal-zone = 2;
          #hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          critical-threshold = 80;
          format = "{temperatureC}°{icon}";
          format-critical = "{temperatureC}°{icon}";
          format-icons = [ "" ];
        };

        "battery" = {
          states = {
            good = 95;
            warning = 20;
            critical = 10;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
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
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "睊";
        };

        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
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
          escape = true;
          max-length = 48;
        };
      };
    };

    # Style Configuration (CSS)
    style = ''
            * {
              font-family: "A-OTF Shin Go Pro B", "Font Awesome 6 Free", "MesloLGS NF Regular", "MesloLGS NF:style=Regular", "MesloLGS NF";
              font-size: 12px;
            }

            @define-color base   #1e1e2e;
            @define-color mantle #181825;
            @define-color crust  #11111b;

            @define-color text     #cdd6f4;
            @define-color subtext0 #a6adc8;
            @define-color subtext1 #bac2de;

            @define-color surface0 #313244;
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

            window#waybar {
              background-color: alpha(#1e1e2e, 0.8);
              color: @text;
              transition-property: background-color;
              transition-duration: .5s;
            }

            window#waybar.hidden {
              opacity: 0.2;
            }

            /*
            window#waybar.empty {
              background-color: transparent;
            }
            window#waybar.solo {
              background-color: #FFFFFF;
            }
            */

            button {
              border: none;
              border-radius: 0;
              margin: 2px;
            }

            button:hover {
              background: inherit;
            }

            #workspaces button {
              padding: 0 12px;
              border-radius: 0px;
              background-color: @surface0;
              color: #ffffff;
              margin: 2px 2px;
            }

            #workspaces button:hover {
              background: @surface0;
            }

            #workspaces button.active {
              background-color: @surface1;
              color: @mauve;
            }

            #workspaces button.urgent {
              background-color: @red;
            }

            #workspaces button:first-child {
              border-top-left-radius: 2px;
              border-bottom-left-radius: 2px;
              margin-left: 2px;
            }

            /* Remove margin on last button */
              #workspaces button:last-child {
              margin-right: 0px;
            }

            #mode {
              background-color: #64727D;
              border-bottom: 3px solid @subtext1;
            }

            #clock,
            #battery,
            #cpu,
            #memory,
            #disk,
            #temperature,
            #backlight,
            #network,
            #pulseaudio,
            #wireplumber,
            #custom-media,
            #tray,
            #mode,
            #idle_inhibitor,
            #scratchpad,
            #mpd {
              padding: 0 10px;
              color: @text;
            }

            #window,
            #workspaces {
              margin: 0 4px;
            }

            /* If workspaces is the leftmost module, omit left margin */
            .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
            }

            /* If workspaces is the rightmost module, omit right margin */
            .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
            }

            #clock {
              background-color: @surface0;
              color: @flamingo;
              border-top-right-radius: 2px;
              border-bottom-right-radius: 2px;
              margin: 2px 2px;
            }

            #battery {
              background-color: @surface0;
              color: @pink;
      	      margin: 2px 2px;
            }

            #battery.charging, #battery.plugged {
              color: @green;
              background-color: @surface0;
            }

            @keyframes blink {
              to {
                background-color: @subtext1;
                color: #000000;
              }
            }

            #battery.critical:not(.charging) {
              background-color: @red;
              color: @crust;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
            }

            label:focus {
              background-color: @crust;
            }

            #cpu {
              background-color: @surface0;
              color: @red;
              margin: 2px 2px;
            }

            #memory {
              background-color: @surface0;
              color: @green;
              margin: 2px 2px;
            }

            #disk {
              background-color: #964B00;
            }

            #backlight {
              background-color: #90b1b1;
            }

            #network {
              background-color: @surface0;
              color: @maroon;
              margin: 2px 2px;
            }

            #network.disconnected {
              background-color: @red;
            }

            #pulseaudio {
              background-color: @surface0;
              color: @peach;
              margin: 2px 2px;
            }

            #pulseaudio.muted {
              background-color: @surface1;
              color: #f38ba8;
            }

            #wireplumber {
              background-color: #fff0f5;
              color: #000000;
            }

            #wireplumber.muted {
              background-color: @red;
            }

            #custom-waybar-mpris {
              background-color: @surface0;
              color: @mauve;
              min-width: 100px;
              border-radius: 15px;
              margin: 2px 2px;
              padding: 6px;
            }

            #custom-media.custom-spotify {
              background-color: @surface0;
            }

            #custom-media.custom-vlc {
              background-color: @peach;
            }

            #temperature {
              background-color: @surface0;
              color: @mauve;
              margin: 2px 2px;
            }

            #temperature.critical {
              background-color: #eb4d4b;
            }

            #tray {
              background-color: @surface0;
              color: @text;
              border-top-left-radius: 15px;
              border-bottom-left-radius: 15px;
              margin-right: 2px;
              margin: 2px 2px;
            }

            #tray > .passive {
              -gtk-icon-effect: dim;
            }

            #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #eb4d4b;
            }     

            #idle_inhibitor {
              background-color: #2d3436;
            }

            #idle_inhibitor.activated {
              background-color: #ecf0f1;
              color: #2d3436;
            }

            #mpd {
              background-color: #66cc99;
              color: #2a5c45;
            }

            #mpd.disconnected {
               background-color: #f53c3c;
            }

            #mpd.stopped {
              background-color: #90b1b1;
            }

            #mpd.paused {
              background-color: #51a37a;
            }   

            #language {
              background: #00b093;
              color: #740864;
              padding: 0 2px;
              margin: 0 5px;
              min-width: 16px;
            }

            #keyboard-state {
              background: #97e1ad;
              color: #000000;
              padding: 0 0px;
              margin: 0 2px;
              min-width: 16px;
            }

            #keyboard-state > label {
              padding: 0 2px;
            }

            #keyboard-state > label.locked {
              background: rgba(0, 0, 0, 0.2);
            }

            #scratchpad {
              background: rgba(0, 0, 0, 0.2);
            }

            #scratchpad.empty {
      	      background-color: transparent;
            }

            /* Focused window */
            #window {
              background-color: @surface0;
              color: @text;
              border-top-right-radius: 15px;
              border-bottom-right-radius: 15px;
              padding: 0 12px;
              margin: 2px 0px;
           }
    '';
  };
}
