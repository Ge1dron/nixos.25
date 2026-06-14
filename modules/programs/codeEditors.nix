{ config, lib, pkgs, ... }: 

let
  cfg = config.modules.programs.codeEditors;
in

{
  options.modules.programs.codeEditors = {
    enable = lib.mkEnableOption "Code editors configuration file";
  };
  config = lib.mkIf cfg.enable {
    # ==== arduino ====
    /*
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
      arduino-ide = {
          executable = "${pkgs.arduino-ide}/bin/arduino-ide";
          extraArgs = [ "--net=none" ];
      };
      };
    };

    programs.firejail.wrappedBinaries = {
      arduino-ide = {
      executable = "${pkgs.arduino-ide}/bin/arduino-ide";
        extraArgs = [ 
            "--net=none" 
            "--ignore=noroot"           # Критично для bwrap
            "--unprivileged-userns"     # Позволяет создавать user namespaces
            "--dbus-user=filter"        # Часто нужно для Electron
        ];
      };
    };
    */
    # ==== Visual Studio Code ==== 
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        arcticicestudio.nord-visual-studio-code
        yzhang.markdown-all-in-one
        bbenoist.nix
        github.copilot
        xaver.clang-format
        fortran-lang.linter-gfortran
        bierner.github-markdown-preview
        ms-vscode.hexeditor
        ms-vscode.cpptools
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "language-gas-x86";
        publisher = "basdp";
        version = "0.0.2";
        sha256 = "PbXhOsoR0/5wXuFrzwCcauM1uGgfQoSRTj0gPVVZ4Kg=";
      } 
      {
        name = "vscode-ollama";
        publisher = "warm3snow";
        version = "1.2.1";
        sha256 = "rp7F0KU17BG1e18oB1/law0hnnxAn2MxqB3fvYcYXMA=";
      }
      ];
    };
  };
}