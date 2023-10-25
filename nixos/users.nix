{ pkgs, ... }: {
  users = {
    defaultUserShell = pkgs.fish;
    users = {
      ju = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };
    };
  };
}
