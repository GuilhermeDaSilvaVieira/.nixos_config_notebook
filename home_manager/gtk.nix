{ pkgs, ... }: {
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.volantes-cursors;
      name = "volantes_cursors";
      size = 36;
    };
    theme = {
      package = pkgs.nordic;
      name = "Nordic-bluish-accent";
    };
    iconTheme = {
      package = pkgs.tela-circle-icon-theme;
      name = "Tela-circle";
    };
  };

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.volantes-cursors;
    name = "volantes_cursors";
    size = 36;
    gtk.enable = true;
  };
}
