{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    layout = "br";
    excludePackages = with pkgs; [ xterm ];
    displayManager.startx.enable = true;
    windowManager.awesome.enable = true;
  };
}
