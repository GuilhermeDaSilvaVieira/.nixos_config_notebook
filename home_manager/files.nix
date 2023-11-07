{ config, ... }: {
  home.file = {
    # Dotfiles
    "${config.xdg.configHome}/cava".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos_config_notebook/.dotfiles/cava";
    "${config.xdg.configHome}/helix".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos_config_notebook/.dotfiles/helix";

    "${config.home.homeDirectory}/.local/share/applications/spotify-adblock.desktop".text = '' 
        [Desktop Entry]
        Type=Application
        Name=Spotify (adblock)
        GenericName=Music Player
        Icon=spotify-client
        TryExec=spotify
        Exec=env LD_PRELOAD=/usr/local/lib/spotify-adblock.so spotify %U
        Terminal=false
        MimeType=x-scheme-handler/spotify;
        Categories=Audio;Music;Player;AudioVideo;
        StartupWMClass=spotify      
      '';
   };
}
