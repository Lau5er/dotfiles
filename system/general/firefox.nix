{ ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      "PasswordManagerEnabled" = false;
      "OfferToSaveLogins" = false;
      "Homepage" = {
        "URL" = "http://dxp4800plus:3000/";
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
      };
    };
    preferences = {
      "browser.newtabpage.enabled" = false;
      "browser.newtabpage.location" = "http://dxp4800plus:3000/";
    };
  };
}
