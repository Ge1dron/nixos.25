{ config, lib, pkgs, ... }:

let
  secrets = import ../../secrets.nix;
  cfg = config.modules.system.networks;
in

{
  options.modules.system.networks = {
    enable = lib.mkEnableOption "networks configuration";
  };

  # Все настройки системы должны находиться внутри этого блока
  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        "Home-WiFi" = {
          connection = { id = "Home-WiFi"; type = "wifi"; };
          wifi = { 
            ssid = secrets.homeSsid; 
          };
          wifi-security = { 
            key-mgmt = "wpa-psk"; 
            psk = secrets.homePass; 
          };
        };
      };
    };
    # "Work-WiFi" = {
    #   connection = { id = "Work-WiFi"; type = "wifi"; };
    #   wifi = { ssid = secrets.workSsid; };
    #   wifi-security = { key-mgmt = "wpa-eap"; };
    #   "802-1x" = {
    #     eap = "peap";
    #     identity = secrets.workLogin;
    #     password = secrets.workPass;
    #     phase2-auth = "mschapv2";
    #   };
    # };

    # ==== proxy client ====
    programs = {
      throne.enable = true;
      throne.tunMode.enable = true;
    };

    services.resolved.enable = true;
    environment.systemPackages = with pkgs;  [
      throne
    ];
  };
}
