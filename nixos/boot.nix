{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };
  };
}
