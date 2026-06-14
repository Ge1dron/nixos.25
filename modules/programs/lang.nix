{ config, lib, pkgs, ... }:

let
  cfg = config.modules.programs.lang;
in

{
  options.modules.programs.lang = {
    enable = lib.mkEnableOption "install programming languages ​​here";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;  [
      nodejs_24
    
      # Компиляторы и среды для матана
      gfortran13
      octave
      octaveFull
    
      # Компиляторы для низкого уровня программирования
      gdb
      gcc
      gnumake
      cmake
      pkg-config
      
      avra
      arduino-ide
      arduino-cli
      avrdude     

      # graphics libraries 

      python3Packages.glad  # <-- Исправлено имя пакета GLAD
      glfw.dev         # <-- ИСПРАВЛЕНО: Добавили .out для glfw 
      glew.dev
      freeglut.dev      # <-- Добавлено .dev
      libGLU.dev       # <-- Добавлено .dev
      libglvnd.dev     # <-- ИСПРАВЛЕНО: Добавили .dev для gl.h
      faad2.dev       # <-- ИСПРАВЛЕНО: Добавили .dev для faad.h
      
      # Веб разработка
      hugo
      go
      caddy
    ];
    environment.sessionVariables = {
      CPATH = "/run/current-system/sw/include";
      C_INCLUDE_PATH = "/run/current-system/sw/include";
      CPLUS_INCLUDE_PATH = "/run/current-system/sw/include";
      LIBRARY_PATH = "/run/current-system/sw/lib";
      CMAKE_PREFIX_PATH = "/run/current-system/sw";

      # Исправленная строка: принудительно задаем как список путей
      LD_LIBRARY_PATH = pkgs.lib.mkForce [ "/run/current-system/sw/lib" ];
    };
    # Принудительно вытаскиваем заголовочные файлы (.h) в /run/current-system/sw/include
    environment.pathsToLink = [ "/include" ];
  };
}