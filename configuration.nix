{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./home.nix ];

  # ssh & boot
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

  # nix system
  system.autoUpgrade. enable = true;
  nix = {
    optimise.automatic = true;
    gc.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraConfig = ''
      Defaults pwfeedback
      Defaults timestamp_timeout = 0
      Defaults lecture = always
      Defaults passprompt = "> "
    '';
  };

  # timezone, networking, locale
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

  # interface & audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.uinput.enable = true;
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];

  # virtualisation
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # user packages
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.steam.enable = true;
  users.defaultUserShell = pkgs.fish;
  services.getty.autologinUser = "raf";
  users.users.raf = {
    isNormalUser = true;
    description = "raf";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" ];
    packages = with pkgs; [
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
  };

  # system packages
  environment.systemPackages = with pkgs; [
    # shell tools
    btop
    detox
    du-dust
    duf
    fastfetch
    gh
    git
    neovim
    p7zip
    rename
    unzip
    wget
    xxd

    # replacement tools
    bat
    fd
    lsd
    ripgrep
    uutils-coreutils-noprefix

    # prompt enhancements
    direnv
    starship
    tmux
    zoxide

    # formatters
    nixpkgs-fmt
    nodePackages.prettier
    nodePackages.sql-formatter
    rustfmt
    shfmt
    stylua
    xmlformat

    # language servers
    clang
    csharp-ls
    elmPackages.elm-language-server
    jdt-language-server
    lemminx
    lua-language-server
    nil
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    python311Packages.python-lsp-server
    rust-analyzer
    sqls
    taplo
    vscode-langservers-extracted
  ];

  # interface fonts
  fonts.packages = with pkgs; [
    (iosevka-bin.override { variant = "sgr-iosevka-term-curly"; }) # system font
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; }) # dev symbols
    sarasa-gothic # chinese, japanese, korean font based on iosevka 
    noto-fonts-monochrome-emoji # emojis that look good in terminal
  ];

  # link user & root dotfiles
  system.activationScripts.dotfiles = {
    text = ''
      rm /root/.config
      ln -s /home/raf/.config/ /root/.config
      chown -R raf /home/raf/.config
    '';
  };

  # ld fix
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    zlib
    nss
    openssl
    curl
    expat
  ];
}
