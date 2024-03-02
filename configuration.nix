{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./home.nix ];

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
      nodePackages.sql-formatter
      jetbrains.idea-community
      nodePackages.prettier
      wl-clipboard
      speedtest-rs
      dotnet-sdk_8
      transmission
      xmlformat
      onefetch
      qrencode
      cliphist
      python3
      nodejs
      mprocs
      stylua
      kitty
      thokr
      rofi
      fzf
      mpv
      jq
    ];
  };

  environment.systemPackages = with pkgs; [
    uutils-coreutils-noprefix
    unstable.cargo
    nixpkgs-fmt
    fastfetch
    starship
    du-dust
    ripgrep
    zoxide
    direnv
    neovim
    shfmt
    unzip
    p7zip
    btop
    wget
    tmux
    git
    bat
    lsd
    xxd
    duf
    nil
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
