{ ... }:

let
    nixos-hardware = builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
in
{
  imports = [
    "${nixos-hardware}/framework/13-inch/7040-amd"
    ./hardware-configuration.nix
    ./modules/linux
    ./modules/environment
    ./modules/home
    ./modules/hyprland
    ./modules/firefox
    ./modules/fonts
  ];

  system.stateVersion = "23.11";
  time.timeZone = "Europe/London";
  networking = {
      hostName = "FRMWRK";
      networkmanager = {
          enable = true;
          wifi.backend = "iwd";
      };
  };

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
  };

  services.openssh.enable = true;
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

system.activationScripts.dotfiles = {
text = ''
if [ -L /root/.config ]; then
    rm /root/.config
elif [ -d /root/.config ]; then
    rm -rf /root/.config
fi

ln -s /home/raf/.config /root/.config
# chown -R raf /home/raf/.config
'';
};
}
