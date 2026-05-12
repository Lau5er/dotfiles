{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    policies = {
      "PasswordManagerEnabled" = false;
      "OfferToSaveLogins" = false;

      "Homepage" = {
        "URL" = "http://dxp4800plus:3000/";
        # WIEDER GEÄNDERT: Stellt deine Tabs beim Browserstart wieder her
        "StartPage" = "previous-session";
      };

      "ExtensionSettings" = {
        "uBlock0@raymondhill.net" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "keepassxc-browser@keepassxc.org" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
        };
        "newtaboverride@agenedia.com" = {
          "installation_mode" = "force_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/new-tab-override/latest.xpi";
        };
      };

      "3rdparty" = {
        "Extensions" = {
          "newtaboverride@agenedia.com" = {
            "url" = "http://dxp4800plus:3000/";
          };
        };
      };
    };
  };
}
