{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  services.openssh.enable = true;
  boot = {
    kernelParams = [ "joydev" "usbhid" "quiet" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 20;
      };
    };
  };

  system.autoUpgrade = {
    enable = true;
  };

  networking.hostName = "SHAGOHOD";
  system.stateVersion = "23.11";
  time.timeZone = "Europe/London";
  networking.networkmanager.enable = true;

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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import
        (
          fetchTarball
            "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
        )
        { };
    };
  };

  security.sudo.enable = false;
  security.doas.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.steam.enable = true;
  users.defaultUserShell = pkgs.fish;
  services.getty.autologinUser = "raf";
  users.users.raf = {
    isNormalUser = true;
    description = "raf";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      librewolf
      kitty
      fastfetch
      rofi
      wl-clipboard
      cliphist
      xmlformat
      nodePackages.sql-formatter
      nodePackages.prettier
      jetbrains.idea-community
      fzf
      mprocs
      onefetch
      thokr
      speedtest-rs
      qrencode
      transmission
    ];
  };

  environment.systemPackages = with pkgs; [
    unstable.cargo
    btop
    gcc
    git
    bat
    lsd
    starship
    zoxide
    direnv
    neovim
    xxd
    nodejs
    jq
    unzip
    ripgrep
    dotnet-sdk_8
    python3
    duf
    wget
    tmux
    nil
    nixpkgs-fmt
    shfmt
    du-dust
    p7zip
    gh
  ];

  hardware.uinput.enable = true;
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];

  fonts.packages = with pkgs; [
    sarasa-gothic
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  system.activationScripts.dotfiles = {
    text = ''
      rm /root/.config
      ln -s /home/raf/.config/ /root/.config
      chown -R raf /home/raf/.config
    '';
  };
}
