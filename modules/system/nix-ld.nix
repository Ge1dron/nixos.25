{ config, lib, pkgs, ... }:

let
  cfg = config.modules.system.nix-ld;
  # Собираем все библиотеки в один список для повторного использования
  ldLibs = with pkgs; [
    glfw
    glew.out
    freeglut.out
    libGLU.out
    libGL
    libglvnd.out
    faac
    faad2.out
    xorg.libX11
    stdenv.cc.cc.lib
  ];
in
{
  options.modules.system.nix-ld = {
    enable = lib.mkEnableOption "nix-ld configuration";
  };

  config = lib.mkIf cfg.enable {
    # 1. Включаем сам nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = ldLibs;
    };

    # 2. Создаем плоскую папку /run/media-libs/ со всеми .so файлами для компилятора
    system.activationScripts.media-libs = {
      text = ''
        mkdir -p /run/media-libs
        rm -rf /run/media-libs/*
        ${lib.concatMapStringsSep "\n" (pkg: "ln -sf ${pkg}/lib/* /run/media-libs/ 2>/dev/null || true") ldLibs}
      '';
    };
  };
}
