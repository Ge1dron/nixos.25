{ config, lib, pkgs, ... }: {
  imports = [
    ./ai.nix
    ./browsers.nix
    ./codeEditors.nix
    ./games.nix
    ./git.nix
    ./lang.nix
  ];
    
  modules.programs = {
    games.enable = true;
    browsers.enable = true;
    ai.enable = true;
    git.enable = true;
    codeEditors.enable = true;
    lang.enable = true;
  };
}
