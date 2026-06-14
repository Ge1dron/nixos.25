{ config, lib, pkgs, ... }:

let
  cfg = config.modules.system.nvidia;
in

{
  options.modules.system.nvidia = {
    enable = lib.mkEnableOption "gpu configuration";
  };

  # Все настройки системы должны находиться внутри этого блока
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  
    services.xserver.videoDrivers = [ "nvidia" ];
    nixpkgs.config.allowUnfree = true;
  
    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
  
      powerManagement = {
        finegrained = false;
        enable = true;
      };
      
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # Make sure to use the correct Bus ID values for your system!
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
      };
    };
  };
}
