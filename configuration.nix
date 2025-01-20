{ pkgs, ... }:

let
  STATE_VERSION = "24.11";
  USER = "raf";
  LOCALE = "en_GB.UTF-8";

  nixos-hardware = builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${STATE_VERSION}.tar.gz";
in
{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
      unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
        inherit pkgs;
      };
    };
  };

  imports = [
    "${nixos-hardware}/framework/13-inch/7040-amd"
    "${home-manager}/nixos"
    ./modules/linux
    ./modules/environment
    ./modules/home
    ./modules/plasma
    ./modules/firefox
    ./modules/fonts
    ./modules/formatters
    ./modules/egpu
    ./modules/steam
    ./modules/virtualisation
    ./modules/mpd
  ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "amd_pstate=passive"
      "smt=on"
    ];
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    udev.packages = [ pkgs.bolt ];
    hardware.bolt.enable = true;
    power-profiles-daemon.enable = true;
    xserver.synaptics.palmDetect = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "passive";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd ];
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  networking = {
    hostName = "FRMWRK";
    firewall.enable = true;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
  };

  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = LOCALE;
    extraLocaleSettings = {
      LC_ADDRESS = LOCALE;
      LC_IDENTIFICATION = LOCALE;
      LC_MEASUREMENT = LOCALE;
      LC_MONETARY = LOCALE;
      LC_NAME = LOCALE;
      LC_PAPER = LOCALE;
      LC_TELEPHONE = LOCALE;
      HOST_LC_ALL = LOCALE;
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
}
