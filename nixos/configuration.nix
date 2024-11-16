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
      (retroarch.override {
        cores = with libretro; [
          nestopia
          snes9x
          dolphin
          # mupen64plus
        ];
      })
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
        withOpenASAR = true;
        # withVencord = true;
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
        "android" = {
          id = "D2Y4UI3-JK6KKC7-B76MTHL-XAQD6HH-PLTVUOO-JIAHYXW-QSOPFQ5-F7BWJQZ";
        };
      };
      folders = {
        "Obsidian" = {
          path = "/home/${user}/Documents/Obsidian";
          devices = [ "android" ];
        };
      };
    };
  };

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
