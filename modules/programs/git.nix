{ config, lib, pkgs, ... }: 

let
  secrets = import ../../secrets.nix;
  cfg = config.modules.programs.git;
in

{
  options.modules.programs.git = {
    enable = lib.mkEnableOption "git installation and configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        user.email = secrets.leshiiEmail;
        user.name = "leshii";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        push = {
          autoSetupRemote = true;
          default = "simple";
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
      };
    };
  };
}