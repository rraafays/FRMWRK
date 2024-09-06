{ pkgs, ... }:

let
    STATE_VERSION = "24.05";
    USER = "raf";

    nixos-hardware = builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${STATE_VERSION}.tar.gz";
in
{
  imports = [
    "${nixos-hardware}/framework/13-inch/7040-amd"
    "${home-manager}/nixos"

    ./modules/linux
    ./modules/environment
    ./modules/home
    ./modules/hyprland
    ./modules/firefox
    ./modules/fonts
  ];

    services.greetd = {
        enable = true;
        settings = {
            initial_session = {
                command = "${pkgs.hyprland}/bin/Hyprland";
                user = "${USER}";
            };
            default_session = {
                command = "${pkgs.hyprland}/bin/Hyprland";
                user = "${USER}";
            };
        };
    };

  users = {
      defaultUserShell = pkgs.fish;
      users.${USER} = {
        isNormalUser = true;
        description = "user";
        extraGroups = [
          "networkmanager"
          "wheel"
          "input"
          "docker"
        ];
      };
  };

  home-manager.users.${USER}.home.stateVersion = "${STATE_VERSION}";
  system = {
      stateVersion = "${STATE_VERSION}";
      activationScripts.dotfiles = {
      text = ''
        if [ -L /root/.config ]; then
            rm /root/.config
        elif [ -d /root/.config ]; then
            rm -rf /root/.config
        fi
        ln -s /home/${USER}/.config /root/.config
        chown -R ${USER} /home/${USER}/.config
        '';
      };
  };

  i18n = {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
      };
  };

  time.timeZone = "Europe/London";

  networking = {
      hostName = "FRMWRK";
      networkmanager = {
          enable = true;
          wifi.backend = "wpa_supplicant";
      };
  };

  boot = {
    kernelParams = [
      "quiet"
      "usbhid"
      "uinput"
      "joydev"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 20;
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };

  services.openssh.enable = true;
}
