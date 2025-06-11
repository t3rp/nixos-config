{ 
  config, 
  pkgs, 
  lib, 
  ... 
}: 

{
  # Packages
  home.packages = with pkgs; [
    adwaita-qt
    gnome.gnome-themes-extra
    gnome.adwaita-icon-theme
  ];

  # GTK dark 
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  # Qt dark 
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # Environment variables
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # Firefox
  programs.firefox = {
    profiles.default = {
      settings = {
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0; # Dark
        "browser.theme.toolbar-theme" = 0; # Dark
      };
    };
  };
}