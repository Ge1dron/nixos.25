{ config, lib, pkgs, ... }: 

let
  cfg = config.modules.programs.games;
in

{
  options.modules.programs.games = {
    enable = lib.mkEnableOption "games and gaming platforms installation and configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        temurin-bin-21
        temurin-bin-8
        temurin-bin-17
      ];
    })
      # Пакеты Steam и Gamescope
      steam
      gamescope
      gamescope-wsi

      # wine
      wineWow64Packages.stable
      wine64
      libkrb5
      winetricks
      wineWow64Packages.waylandFull
    ];

    # === Настройки игровых программ ===
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;      
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };

      gamemode.enable = true;

      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };

    # === Переменные окружения ===
    environment.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet";
    };
  };
}
