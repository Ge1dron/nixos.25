{ config, lib, pkgs, ... }:

let
  # Извлекаем конфиг именно из ветки modules.boot.grub
  cfg = config.modules.system.grub;
  
  kawaiiGrubTheme = pkgs.stdenv.mkDerivation {
    pname = "kawaii-grub";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "Gabbar-v7";
      repo = "KawaiiGRUB";
      rev = "master";
      sha256 = "sha256-vc6u93odDXVWBAAAi+r9fGlBp0qiVzzXy8IL6H8WLjo=";
    };
    installPhase = "mkdir -p $out && cp -r ./* $out/";
  };
in

{
  # Повторяем вложенную структуру, чтобы Nix понимал вызов "boot.grub.enable"
  options.modules.system.grub = {
    enable = lib.mkEnableOption "GRUB bootloader configuration";
  };

  config = lib.mkIf cfg.enable {
    # ==== GRUB ====
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      timeout = 10;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        default = "1";
        
        # Исправленные пути под репозиторий Gabbar-v7/KawaiiGRUB
        theme = "${kawaiiGrubTheme}/kawaii-grub-theme";
        font = "${kawaiiGrubTheme}/kawaii-grub-theme/terminus-18.pf2";

        gfxmodeEfi = "1920x1080"; 
        gfxpayloadEfi = "keep"; 

        extraConfig = ''
          insmod all_video
          insmod gfxterm
          insmod png
          insmod jpeg
          insmod ext2
          
          # Динамический путь к теме вместо захардкоженного хэша
          search --set=root --file ${kawaiiGrubTheme}/KawaiiGRUB-Theme/theme.txt
  
          terminal_output gfxterm
          
          menuentry "UEFI Firmware Settings" --class efi {
            fwsetup
          }
        '';
      };
    };
  };
}
