{ lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = null;
    portalPackage = null;
    xwayland.enable = true;
    settings = {
      monitor = [
        "eDP-1,preferred,0x0,1.333333"
        "HDMI-A-1,1920x1080@60,auto-center-right,1,transform,3"
        "DP-2,highrr,0x0,1,vrr,2"
      ];

      # Keybinds
      "$mod" = "SUPER";
      bind = [
        # Terminal
        "$mod, Return, exec, kitty"

        # Exit things
        "$mod, q, killactive,"
        "$mod, m, exec, uwsm stop"

        # Rofi
        ''$mod, r, exec, rofi -show drun -run-command "uwsm app -- {cmd}"''
        "$mod, w, exec, rofi -show window"
        "$mod, v, exec, rofi -show clipboard"

        # Manage windows
        "$mod, n, movefocus, l"
        "$mod, o, movefocus, r"
        "$mod, e, movefocus, u"
        "$mod, i, movefocus, d"
        "$mod shift, n, movewindow, l"
        "$mod shift, o, movewindow, r"
        "$mod shift, e, movewindow, u"
        "$mod shift, i, movewindow, d"
        "$mod, F, fullscreen,"
        "$mod, J, togglesplit,"
        "$mod, space, togglefloating,"
        "$mod, P, pin"

        # Special workspace
        "$mod, t, togglespecialworkspace,"
        "$mod SHIFT, t, movetoworkspace, special"

        # Lock
        "$mod, L, exec, uwsm app -- hyprlock"

        # Apps
        "$mod, X, exec, uwsm app -- kitty fish -C y"
        "$mod SHIFT, X, exec, uwsm app -- thunar"
        "$mod, B, exec, uwsm app -- vivaldi"

        # Screenshots
        ", Print, exec, hyprshot -m output --freeze --output-folder ~/Pictures/screenshots"
        "$mod SHIFT, S, exec, hyprshot -m region --freeze --output-folder ~/Pictures/screenshots"
        "$mod CONTROL, S, exec, hyprshot -m region --freeze --raw | satty --filename -"
        "$mod ALT, S, exec, hyprshot -m window --freeze --output-folder ~/Pictures/screenshots"

        # Power menu
        "$mod SHIFT, F, exec, nwg-bar"

        # GSR
        "$mod, G, exec, bash ~/.config/hypr/replay/save.sh"
        "$mod SHIFT, G, exec, uwsm app -- nwg-bar -t ~/.config/hypr/replay/nwg-bar/bar.json"

      ]
      ++ (
        # Worspace switching
        builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) 10
        )
      );

      # Binds that repeat
      binde = [
        # Media
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ",XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"

        # Window resizing
        "$mod control, n, resizeactive, -40 0"
        "$mod control, o, resizeactive, 40 0"
        "$mod control, e, resizeactive, 0 -40"
        "$mod control, i, resizeactive, 0 40"
      ];

      # Mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "colemak";

        accel_profile = "flat";
        mouse_refocus = false;
        touchpad = {
          disable_while_typing = false;
        };
        repeat_rate = 50;
      };

      device = {
        name = "pixa3854:00-093a:0274-touchpad";
        accel_profile = "adaptive";
      };

      exec-once = [
        "uwsm app -s b waybar" # TODO properly start these programs as systemd-services
        "uwsm app -s b mako"
        "[workspace 1 silent] uwsm app -- kitty"
        "[workspace 2 silent] uwsm app -- floorp"
        "[workspace 4 silent] uwsm app -- vesktop"
        "[workspace 5 silent] uwsm app -- steam -silent"
        "uwsm app -s b systemctl --user start hyprpolkitagent"
        "uwsm app -s b -- waypaper --restore"
        "uwsm app -s b -- wl-paste --type text --watch cliphist store"
        "uwsm app -s b -- wl-paste --type image --watch cliphist store"
        #"uwsm app -s b -- easyeffects --gapplication-service"
        #"~/.config/hypr/replay/start.sh" # Uncomment to enable GSR on start
      ];

      decoration = {
        rounding = 15;
        inactive_opacity = 1.0;
        shadow.enabled = false;
        blur = {
          enabled = true;
          size = 9;
          passes = 2;
          new_optimizations = true;
          noise = 0.02;
          brightness = 0.90;
          xray = true;
          ignore_opacity = true;
        };
      };

      animations = {
        enabled = true;
        "bezier" = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];
        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "windowsIn, 1, 3, md3_decel, popin 60%"
          "windowsOut, 1, 3, md3_accel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 3, md3_decel"
          "layersIn, 1, 3, menu_decel, slide"
          "layersOut, 1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2, menu_decel"
          "fadeLayersOut, 1, 0.5, menu_accel"
          "workspaces, 1, 7, menu_decel, slide"
        ];
      };

      general = {
        gaps_in = 2;
        gaps_out = 6;
        border_size = 2;
        "col.active_border" = lib.mkForce "rgb(cba6f7)";
        #"col.inactive_border" = "rgb(45475a)";
        #allow_tearing = true;
      };

      misc = {
        vfr = 1;
        vrr = 1;
        #animate_manual_resizes = true;
        #animate_mouse_windowdragging = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        #disable_autoreload = true;
      };

      windowrule = [
        "match:class kitty, workspace 1"
        "match:class firefox, workspace 2"
        "match:class floorp, workspace 2"
        "match:class vesktop, workspace 4"
        "match:class waydroid, fullscreen 1"
        "match:class ^$, match:title ^$, match:xwayland true, match:float true; match:fullscreen false; match:pin false, no_focus 1"
        "border_size 0, match:float 0, match:workspace w[tv1]"
        "rounding 0, match:float 0, match:workspace w[tv1]"
        "border_size 0, match:float 0, match:workspace f[1]"
        "rounding 0, match:float 0, match:workspace f[1]"
      ];

      workspace = [
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      layerrule = [
        "match:namespace waybar, blur true"
        "match:namespace waybar, xray true"
        #"match:namespace waybar, no_anim = true"
      ];

      render = {
        direct_scanout = 1;
        cm_fs_passthrough = 1;
        cm_auto_hdr = 2;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      cursor = {
        enable_hyprcursor = false;
        no_hardware_cursors = false;
        #use_cpu_buffer = true;
        #no_break_fs_vrr = true;
        #min_refresh_rate = 48;
        #hide_on_key_press = true;
      };

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        #"XDG_MENU_PREFIX,plasma-"
      ];

      dwindle = {
        preserve_split = true;
        pseudotile = true;
      };
    };
  };
}
