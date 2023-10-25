{ pkgs, ... }: {
  environment = {
    defaultPackages =  [];
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

      libnotify
      exiftool

      #### Party tricks
      cmatrix
      cowsay
      sl
      lolcat
      figlet
 
      #### Browser
      librewolf-wayland
      (ungoogled-chromium.override {
        commandLineArgs = [
          "--force-device-scale-factor=1"
          "--enable-blink-features=MiddleClickAutoscroll"
        ];
      })
      firefox

      #### Media
      yt-dlp
      cava
      pavucontrol
      zathura
      lf
      pcmanfm
      libreoffice-still
      ffmpeg
      ffmpegthumbnailer
      mpv
      thunderbird
      cinnamon.warpinator
      virt-manager
      blueman

      # Editors
      helix 

      #### Proprietary
      (discord.override {
        withOpenASAR = true;
        # withVencord = true;
      })
      obsidian
      spotify

      starship
      redshift
      feh
      bat
      p7zip
      freshfetch
      neofetch
      trash-cli
      fzf
      fd
      ripgrep
      btop
      eza
      kitty
    ];
  };
}
