# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
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
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   awesome = inputs.nixpkgs-f2k.packages.${final.system}.awesome-luajit-git;
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [ "electron-25.9.0" ];
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # FIXME: Add the rest of your current configuration
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
      # TODO: Rewrite groups of packages like 'Core'
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
      librewolf-wayland
      ungoogled-chromium
      firefox

      # Emulators
      (retroarch.override {
        cores = with libretro; [
          nestopia
          snes9x
          dolphin
          # mupen64plus
        ];
      })
      space-cadet-pinball

      #### Media
      yt-dlp
      cava
      pavucontrol
      libreoffice-still
      cinnamon.warpinator
      gimp
      transmission_4-gtk

      # Editors
      helix

      #### Proprietary
      (discord.override {
        withOpenASAR = true;
        # withVencord = true;
      })
      stable.obsidian
      spotify

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
        42000 # Warpinator
        42001 # Warpinator

        8384 # Syncthing
        22000 # Syncthing
      ];
      allowedUDPPorts = [
        42000 # Warpinator
        42001 # Warpinator

        22000 # Syncthing
        21027 # Syncthing
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
      systemd-boot.enable = true;
      timeout = 0;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";
  time.hardwareClockInLocalTime = true;

  # Fonts
  fonts = {
    packages = with pkgs; [
      nerdfonts
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
  };

  services.displayManager.sddm.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
    browsing = true;
    defaultShared = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
  };

  # services.tlp.enable = true;
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;

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

  hardware.bluetooth = {
    enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
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
        "text/html" = "librewolf.desktop";
        "text/xml" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
        "x-scheme-handler/mailto" = "librewolf.desktop";
        "x-scheme-handler/webcal" = "librewolf.desktop";
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  # powerManagement.cpuFreqGovernor = "powersave";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
