{
  programs.niri.settings = {
    # ─── Input ────────────────────────────────────────────────────────────────

    prefer-no-csd = true;

    input = {
      keyboard = {
        # Empty xkb = niri reads from org.freedesktop.locale1 (localectl)
        repeat-rate = 35;
        repeat-delay = 200;

        xkb = {
          # layout  = "us,ru";
          # options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
        };
        numlock = true;
      };

      touchpad = {
        tap = true;
        natural-scroll = true;
        # dwt                        = true;
        # dwtp                       = true;
        # drag                       = false;
        # drag-lock                  = true;
        # accel-speed                = 0.2;
        # accel-profile              = "flat";
        # scroll-method              = "two-finger";
        # disabled-on-external-mouse = true;
      };

      # mouse and trackpoint: all defaults, nothing to set

      # warp-mouse-to-focus.enable = true;
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    # ─── Outputs ──────────────────────────────────────────────────────────────
    # Find output names with: niri msg outputs

    outputs."LVDS-1" = {
      # enable = false;
      mode = {
        width = 1366;
        height = 768;
        refresh = 60.044;
      };
      scale = 1.0;
      transform.rotation = 0;
      position = {
        x = 0;
        y = 0;
      };
    };

    # ─── Layout ───────────────────────────────────────────────────────────────

    layout = {
      gaps = 16;
      center-focused-column = "never"; # "never" | "always" | "on-overflow"

      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        # { fixed = 1920; }
      ];

      default-column-width = {
        proportion = 0.5;
      };
      # default-column-width = {}; # let windows decide their width

      # focus-ring.enable defaults to true — matches KDL (nothing to set)
      focus-ring = {
        width = 4;
        # Colors use the <decoration> tagged union: { color = "..."; } or { gradient = {...}; }
        active = {
          color = "#7fc8ff";
        };
        inactive = {
          color = "#505050";
        };
        # active   = { gradient = { from = "#80c8ff"; to = "#c7ff7f"; angle = 45; }; };
        # inactive = { gradient = { from = "#505050"; to = "#808080"; angle = 45;
        #                           relative-to = "workspace-view"; }; };
      };

      border = {
        enable = false; # matches KDL "off"
        width = 4;
        active = {
          color = "#ffc87f";
        };
        inactive = {
          color = "#505050";
        };
        urgent = {
          color = "#9b0000";
        };
        # active = { gradient = { from = "#e5989b"; to = "#ffb4a2"; angle = 45;
        #                         relative-to = "workspace-view"; in' = "oklch longer hue"; }; };
      };

      shadow = {
        # enable = true; # uncomment to enable shadows (default is false)
        # draw-behind-window = true;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#0007";
      };

      # struts left/right/top/bottom all default to 0
    };

    # ─── Startup ──────────────────────────────────────────────────────────────

    spawn-at-startup = [
      # { argv = [ "waybar" ]; }
      { sh = "noctalia-shell"; }
      # { sh = "qs -c ~/source/qs/MyAwesomeShell"; }
    ];

    # ─── Miscellaneous ────────────────────────────────────────────────────────

    # hotkey-overlay.skip-at-startup defaults to false — matches KDL

    # prefer-no-csd = true;

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    # screenshot-path = null; # disable saving to disk

    # animations.enable defaults to true — matches KDL (nothing to set)
    # animations.slowdown = 3.0;

    # ─── Window Rules ─────────────────────────────────────────────────────────

    window-rules = [
      # Work around WezTerm's initial configure bug.
      {
        matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
        default-column-width = { };
      }

      # Firefox Picture-in-Picture — open as floating by default.
      {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }

      # Example: block password managers from screen capture (disabled in KDL with /-).
      # {
      #   matches = [
      #     { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
      #     { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
      #   ];
      #   block-out-from = "screen-capture";
      # }

      # Example: rounded corners for all windows (disabled in KDL with /-).
      # {
      #   geometry-corner-radius = {
      #     top-left = 12.0; top-right = 12.0;
      #     bottom-left = 12.0; bottom-right = 12.0;
      #   };
      #   clip-to-geometry = true;
      # }
    ];

    # ─── Binds ────────────────────────────────────────────────────────────────
    # Actions are attrsets:  action.<name> = <args>
    # Zero-arg actions:      action.close-window = []
    # Single-arg:            action.spawn = "fuzzel"
    # Multi-arg:             action.spawn = [ "sh" "-c" "cmd" ]
    # Indexed (int/string):  action.focus-workspace = 1

    binds = {

      # Hotkey overlay
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      # Launch apps
      "Mod+T" = {
        hotkey-overlay.title = "Open a Terminal: alacritty";
        action.spawn = "alacritty";
      };
      "Mod+B" = {
        hotkey-overlay.title = "Open a Browser: firefox";
        action.spawn = "firefox";
      };
      "Mod+D" = {
        hotkey-overlay.title = "Run an Application: fuzzel";
        action.spawn = "fuzzel";
      };
      "Super+Alt+L" = {
        hotkey-overlay.title = "Lock the Screen: swaylock";
        action.spawn = "swaylock";
      };
      # hotkey-overlay-title=null in KDL → hotkey-overlay.hidden = true in Nix
      "Super+Alt+S" = {
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
        action.spawn = [
          "sh"
          "-c"
          "pkill orca || exec orca"
        ];
      };

      # Volume (PipeWire / WirePlumber)
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];
      };

      # Media keys (playerctl)
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "playerctl play-pause"
        ];
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "playerctl stop"
        ];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "playerctl previous"
        ];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = [
          "sh"
          "-c"
          "playerctl next"
        ];
      };

      # Brightness (brightnessctl — multi-arg spawn, no shell needed)
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "+10%"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "10%-"
        ];
      };

      # Overview & window control
      "Mod+O" = {
        repeat = false;
        action.toggle-overview = [ ];
      };
      "Mod+Q" = {
        repeat = false;
        action.close-window = [ ];
      };

      # Focus movement
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      # Move column/window
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];

      # First / last column
      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      # Monitor focus
      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];

      # Move column to monitor
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

      # Workspace focus
      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];

      # Move column to workspace
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

      # Reorder workspaces
      "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
      "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      # Scroll wheel — workspace (rate-limited)
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = [ ];
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = [ ];
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-down = [ ];
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-up = [ ];
      };

      # Scroll wheel — column
      "Mod+WheelScrollRight".action.focus-column-right = [ ];
      "Mod+WheelScrollLeft".action.focus-column-left = [ ];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

      # Shift+scroll → horizontal
      "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

      # Jump to workspace by index
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      # Move column to workspace by index
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      # Consume / expel windows in columns
      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # Resize
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      # "Mod+M".action.maximize-window-to-edges               = [];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];

      # Width / height fine-tuning (single string arg)
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # Floating & tabbed
      "Mod+V".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
      "Mod+W".action.toggle-column-tabbed-display = [ ];

      # Screenshots
      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # Keyboard shortcuts inhibitor escape hatch
      "Mod+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = [ ];
      };

      # Session management
      "Mod+Shift+E".action.quit = [ ];
      "Ctrl+Alt+Delete".action.quit = [ ];
      "Mod+Shift+P".action.power-off-monitors = [ ];
    };
  };
}
