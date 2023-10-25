{ ... }: {
  # Specify each program separately
  imports = [
    ./fish.nix
    ./dconf.nix
    ./river.nix
    ./xwayland.nix
  ];
}
