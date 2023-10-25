{ ... }: {
  # Specify each service separately
  imports = [
    ./xserver.nix
    ./printing.nix
    ./avahi.nix
    ./greetd.nix
    ./pipewire.nix
    ./udisks2.nix
    ./devmon.nix
    ./picom.nix
    ./transmission.nix
    ./gvfs.nix
  ];
}
