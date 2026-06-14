{ config, pkgs, ... }:

{
  imports = [
    ./grub.nix
    ./networks.nix
    ./nvidia.nix
    ./nix-ld.nix
  ];
  
  modules.system = {
    grub.enable = true;
    networks.enable = true;
    nvidia.enable = true;
    nix-ld.enable = true;
  };
}