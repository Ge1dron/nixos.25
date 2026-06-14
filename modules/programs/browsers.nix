{ config, lib, pkgs, ... }: 

let
  cfg = config.modules.programs.browsers;
in

{
  options.modules.programs.browsers = {
    enable = lib.mkEnableOption "browsers installation and configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox
      chromium
    ];

    programs = {
      firefox = {
        enable = true;
        languagePacks = [ "en-US" "de" "fr" ];
        preferences.status = "user";

        preferences = {
          "browser.startup.page" = 1; 
          "browser.startup.homepage" = "https://duckduckgo.com";
          "browser.newtabpage.enabled" = false; 
        };

        policies = { 
          StartPage = "homepage";
          OverrideFirstRunPage = "https://duckduckgo.com";

          Homepage = {
            URL = "https://duckduckgo.com";
            Locked = true; # Измените на true, чтобы пользователь не мог случайно сбросить её в браузере
            AdditionalUrls = [
              "https://nixos.org"
            ];
          };
          ExtensionSettings = {
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://mozilla.org";
              installation_mode = "force_installed";
            };
            # Dark Reader
            "addon@darkreader.org" = {
              install_url = "https://mozilla.org";
              installation_mode = "force_installed";
            };
            # TWP - Translate Web Pages
            "{76d0fe7a-522b-4fd0-a7e1-9ddf9278da91}" = {
              install_url = "https://mozilla.org";
              installation_mode = "force_installed";
            };
            # Vimium
            "{d7742d87-e61d-4027-b72b-a74ab4ee60df}" = {
              install_url = "https://mozilla.org";
              installation_mode = "force_installed";
            };
          };
        };
      };


      chromium = {
        enable = true;
        
        homepageLocation = "https://nixos.org";

        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "ocfbfclgfffbclmbfbfennoafhbogmfb" # TWP - Translate Web Pages
          "dbepclidomcomjjcjiconbcojgoaocid" # Vimium 
        ];

        extraOpts = {
          "BrowserSignin" = 1; 

          "RestoreOnStartup" = 4; 
          "RestoreOnStartupURLs" = [ "https://duckduckgo.com" ];

          "SyncDisabled" = 1;
          "PasswordManagerEnabled" = 0;
          "SpellcheckEnabled" = 1;
          "SpellcheckLanguage" = [ "ru" "en-US" ];
        };
      };
    };
  };
}
