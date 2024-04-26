{ pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [ (import "${home-manager}/nixos") ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
      unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { };
    };
  };

  security.polkit.enable = true;
  xdg.portal = {
    config.common.default = "*";
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  home-manager.users.raf = {
    programs.git = {
      enable = true;
      userName = "raf";
      userEmail = "rraf@tuta.io";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };
    home.stateVersion = "18.09";
    home.enableNixpkgsReleaseCheck = false;
    home.packages = with pkgs; [
      # development tools
      adbfs-rootless
      android-tools
      jetbrains.idea-ultimate
      kitty

      # terminal tools
      fzf
      jq
      mprocs
      mpv
      openvpn
      speedtest-rs
      thokr

      # interface tools 
      cliphist
      gamescope
      grim
      rofi
      slurp
      wl-clipboard
      xdg-utils

      # file sharing
      soulseekqt
      transmission
      tremc
    ];
    dconf.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true;
      settings = {
        monitor = ",highrr,auto,1,vrr,0";
        bind = [
          "CTRL ALT, DELETE, exec, shutdown now"
          "CTRL ALT, RETURN, exec, beep;beep;beep; reboot"

          ",code:86, exec, kitty"
          ",code:104, exec, rofi -show drun -display-drun \"\""
          ",code:82, exec, firefox"
          "CTRL, code:115, togglefloating"
          "SHIFT, code:115, togglesplit"

          "CTRL, q, killactive"

          "CTRL, h, movefocus, l"
          "CTRL, j, movefocus, d"
          "CTRL, k, movefocus, u"
          "CTRL, l, movefocus, r"

          "CTRL SHIFT, h, swapwindow, l"
          "CTRL SHIFT, j, swapwindow, d"
          "CTRL SHIFT, k, swapwindow, u"
          "CTRL SHIFT, l, swapwindow, r"

          "CTRL, 1, workspace, 1 "
          "CTRL, 2, workspace, 2 "
          "CTRL, 3, workspace, 3 "
          "CTRL, 4, workspace, 4 "
          "CTRL, 5, workspace, 5 "
          "CTRL, 6, workspace, 6 "
          "CTRL, 7, workspace, 7 "
          "CTRL, 8, workspace, 8 "
          "CTRL, 9, workspace, 9 "
          "CTRL, 0, workspace, 10"

          "CTRL SHIFT, 1, movetoworkspace, 1"
          "CTRL SHIFT, 2, movetoworkspace, 2"
          "CTRL SHIFT, 3, movetoworkspace, 3"
          "CTRL SHIFT, 4, movetoworkspace, 4"
          "CTRL SHIFT, 5, movetoworkspace, 5"
          "CTRL SHIFT, 6, movetoworkspace, 6"
          "CTRL SHIFT, 7, movetoworkspace, 7"
          "CTRL SHIFT, 8, movetoworkspace, 8"
          "CTRL SHIFT, 9, movetoworkspace, 9"
          "CTRL SHIFT, 0, movetoworkspace, 10"
        ];
        bindm = [
          "SHIFT, mouse:272, movewindow"
          "SHIFT, mouse:273, resizewindow"
        ];

        exec = [
          "pactl set-sink-volume @DEFAULT_SINK@ 100%"
          "wpctl set-volume @DEFAULT_SINK@ 100%"
          "/home/raf/.config/mouseless/mouseless"
        ];

        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        ];

        input = {
          kb_layout = "us";
          repeat_rate = 150;
          repeat_delay = 200;
          follow_mouse = 1;
          sensitivity = 0;
        };

        general = {
          gaps_in = 10;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "0xFFEBDBB2";
          "col.inactive_border" = "0xFF928373";
          layout = "dwindle";
          allow_tearing = false;
          cursor_inactive_timeout = 1;
          no_cursor_warps = 0;
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = false;
          };
          drop_shadow = false;
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          no_gaps_when_only = 1;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          background_color = "0x000000";
        };

        env = [
          "XCURSOR_SIZE,24"
          "GDK_SCALE,1"
          "WLR_NO_HARDWARE_CURSORS,1"
          "GDK_BACKEND,wayland,x11"
          "QT_QPA_PLATFORM,wayland;xcb"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "BROWSER,firefox"
          "MOZ_ENABLE_WAYLAND,1"
        ];
      };
    };
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            vimium
            sponsorblock
            youtube-recommended-videos
            scroll_anywhere
            darkreader
            zoom-page-we
          ];
          userChrome = ''
            #TabsToolbar { visibility: collapse !important; }
            #main-window:not([customizing]) #navigator-toolbox:not(:focus-within):not(:hover){
                margin-top: -45px;
            }
          '';
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
            "browser.search.region" = "GB";
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "app.normandy.first_run" = false;
            "app.shield.optoutstudies.enabled" = false;
            "app.update.channel" = "default";
            "browser.urlbar.quickactions.enabled" = false;
            "browser.urlbar.quickactions.showPrefs" = false;
            "browser.urlbar.shortcuts.quickactions" = false;
            "browser.urlbar.suggest.quickactions" = false;
            "dom.forms.autocomplete.formatautofill" = false;
            "extensions.update.enabled" = false;
            "extensions.webcompat.enable_picture_in_picture_override" = true;
            "extensions.webcompat.enable_shims" = true;
            "extensions.webcompat.perform_injections" = true;
            "extensions.webcompat.perform_ua_overrides" = true;
            "privacy.donottrackheader.enabled" = true;
            "signon.rememberSignons" = false;
            "browser.formfill.enable" = false;
            "signon.autofillForms" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.formautofill.hueristics.enabled" = false;
          };
        };
      };
    };
  };
}
