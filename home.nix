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
    home.stateVersion = "18.09";
    home.enableNixpkgsReleaseCheck = false;
    home.packages = with pkgs; [
      # development tools
      adbfs-rootless
      android-tools
      dotnet-sdk_8
      jetbrains.idea-community
      kitty
      nodejs
      python3
      unstable.cargo

      # terminal tools
      fzf
      jq
      mprocs
      mpv
      onefetch
      qrencode
      speedtest-rs
      thokr
      transmission

      # interface tools 
      cliphist
      rofi
      wl-clipboard
    ];
    dconf.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true;
      settings = {
        bind = [
          "CTRL, return, exec, kitty"
          "CTRL, space, exec, rofi -show drun -display-drun \"\""
          "CTRL, q, killactive"
          "CTRL, code:35, togglesplit"
          "CTRL, code:47, fullscreen"
          "CTRL, code:48, togglefloating"
          "CTRL, code:61, exec, firefox"
          "CTRL, h, movefocus, l"
          "CTRL, j, movefocus, d"
          "CTRL, k, movefocus, u"
          "CTRL, l, movefocus, r"
        ];

        exec = [
          "pactl set-sink-volume @DEFAULT_SINK@ 100%"
          "wpctl set-volume @DEFAULT_SINK@ 100%"
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
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          background_color = "0x000000";
        };
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
