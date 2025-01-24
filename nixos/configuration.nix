{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  user = "ju";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  environment = {
    variables = {
      FZF_DEFAULT_COMMAND = "fd -H";

      LIBSEAT_BACKEND = "logind";

      WLR_NO_HARDWARE_CURSORS = "1";

      NIXOS_OZONE_WL = "1";

      QT_QPA_PLATFORM = "wayland;xcb";
    };
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      #### Core
      lld
      gcc
      glibc
      clang
      llvmPackages.bintools
      wget
      killall
      zip
      unzip
      exfat
      lm_sensors
      git

      #### Party tricks
      cmatrix
      cowsay
      sl
      lolcat
      figlet

      #### Browser
      inputs.zen-browser.packages."${system}".generic
      # mullvad-browser
      ungoogled-chromium

      # Emulators
      (retroarch.withCores (
        cores: with cores; [
          nestopia
          snes9x
          dolphin
          # mupen64plus
        ]
      ))
      blastem

      space-cadet-pinball

      #### Media
      yt-dlp
      pavucontrol
      libreoffice-still
      localsend
      gimp
      transmission_4-gtk

      # Editors
      helix

      #### Proprietary
      (discord.override {
        # withOpenASAR = true;
        withVencord = true;
      })
      obsidian
      spotify

      # Backup
      rsync

      starship
      zoxide
      bat
      p7zip
      neofetch
      fzf
      fd
      ripgrep
      btop
      eza
    ];
  };

  networking = {
    hostName = "nami";
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [
        # Syncthing
        8384
        22000

        # LocalSend
        53317
      ];
      allowedUDPPorts = [
        # Syncthing
        22000
        21027

        # LocalSend
        53317
      ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "i915.force_probe=0116"
      # Avoid touchpad click to tap (clickpad) bug. For more detail see:
      # https://wiki.archlinux.org/title/Touchpad_Synaptics#Touchpad_does_not_work_after_resuming_from_hibernate/suspend
      "psmouse.synaptics_intertouch=0"
    ];
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        extraConfig = ''
          # Hide GRUB menu by default (instant boot)
          set timeout=0

          # If Shift is pressed, show the GRUB menu
          if keystatus --shift ; then
            set timeout=-1  # Show the GRUB menu indefinitely if Shift is pressed
          fi
        '';
      };
    };
  };

  time.timeZone = "America/Sao_Paulo";
  time.hardwareClockInLocalTime = true;

  fonts = {
    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts._3270
      nerd-fonts.agave
      nerd-fonts.anonymice
      nerd-fonts.arimo
      nerd-fonts.aurulent-sans-mono
      nerd-fonts.bigblue-terminal
      nerd-fonts.bitstream-vera-sans-mono
      nerd-fonts.blex-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.code-new-roman
      nerd-fonts.comic-shanns-mono
      nerd-fonts.commit-mono
      nerd-fonts.cousine
      nerd-fonts.d2coding
      nerd-fonts.daddy-time-mono
      nerd-fonts.departure-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.droid-sans-mono
      nerd-fonts.envy-code-r
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.geist-mono
      nerd-fonts.go-mono
      nerd-fonts.gohufont
      nerd-fonts.hack
      nerd-fonts.hasklug
      nerd-fonts.heavy-data
      nerd-fonts.hurmit
      nerd-fonts.im-writing
      nerd-fonts.inconsolata
      nerd-fonts.inconsolata-go
      nerd-fonts.inconsolata-lgc
      nerd-fonts.intone-mono
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      nerd-fonts.lekton
      nerd-fonts.liberation
      nerd-fonts.lilex
      nerd-fonts.martian-mono
      nerd-fonts.meslo-lg
      nerd-fonts.monaspace
      nerd-fonts.monofur
      nerd-fonts.monoid
      nerd-fonts.mononoki
      nerd-fonts.mplus
      nerd-fonts.noto
      nerd-fonts.open-dyslexic
      nerd-fonts.overpass
      nerd-fonts.profont
      nerd-fonts.proggy-clean-tt
      nerd-fonts.recursive-mono
      nerd-fonts.roboto-mono
      nerd-fonts.shure-tech-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.space-mono
      nerd-fonts.symbols-only
      nerd-fonts.terminess-ttf
      nerd-fonts.tinos
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.victor-mono
      nerd-fonts.zed-mono
      noto-fonts
      noto-fonts-emoji
      corefonts
      vistafonts
    ];
  };

  users = {
    defaultUserShell = pkgs.fish;
    users = {
      ju = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "syncthing"
        ];
      };
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "br";
    excludePackages = with pkgs; [ xterm ];
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.syncthing = {
    enable = true;
    user = user;
    dataDir = "/home/${user}/Documents/Obsidian";
    configDir = "/home/${user}/Documents/Obsidian/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "android_ju" = {
          id = "4ELWBGB-I2GAH7T-PWNVNR3-GLYT7TU-I6NIQTD-CRPSHLG-22JEIYB-MOJJIAV";
        };
      };
      folders = {
        "Obsidian" = {
          path = "/home/${user}/Documents/Obsidian";
          devices = [ "android_ju" ];
        };
      };
    };
  };

  # Fix 20s to open gtk apps
  services.dbus.implementation = "broker";

  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;

  services.pulseaudio.enable = false;

  security = {
    sudo.enable = false;
    rtkit.enable = true;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  programs.fish = {
    enable = true;
  };

  programs.dconf = {
    enable = true;
  };

  programs.xwayland = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  i18n = {
    defaultLocale = "pt_BR.UTF-8"; # Errors, Warnings, ETC ...
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEFONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
    };
    icons.enable = true;
    mime = {
      enable = true;
      defaultApplications = {
        "text/*" = "org.gnome.TextEditor.desktop";
        "text/plain" = "org.gnome.TextEditor.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "application/rdf+xml" = "org.gnome.Evince.desktop";
        "application/rss+xml" = "org.gnome.Evince.desktop";
        "application/xhtml+xml" = "org.gnome.Evince.desktop";
        "application/xhtml_xml" = "org.gnome.Evince.desktop";
        "application/xml" = "org.gnome.Evince.desktop";
        "image/*" = "org.gnome.eog.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";
        "image/gif" = "org.gnome.eog.desktop";
        "image/webp" = "org.gnome.eog.desktop";
        "video/*" = "org.gnome.Totem.desktop";
        "text/html" = "zen.desktop";
        "text/xml" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";
        "x-scheme-handler/mailto" = "zen.desktop";
        "x-scheme-handler/webcal" = "zen.desktop";
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  system.stateVersion = "25.05";
}
