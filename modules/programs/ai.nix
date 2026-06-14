{ config, lib, pkgs, ... }: 

let
  cfg = config.modules.programs.ai;
in

{
  options.modules.programs.ai = {
    enable = lib.mkEnableOption "ai installation and configuration";
  };

  config = lib.mkIf cfg.enable {

    # ==== Ollama, Local AI, Open WebUI ====
    services = { 
      open-webui = {
        enable = true;
        host = "127.0.0.1";
        port = 8080;
        environment = {
          ENABLE_SIGNUP = "False";
          WEBUI_AUTH = "False";
          OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        };
      };
      ollama = {
        enable = true;
        user = "ollama";
        package = pkgs.ollama-cuda;
        # user = "leshii";
        environmentVariables = {
          OLLAMA_MODELS = "/nix/.ollama";
          HOME = "/var/lib/ollama";
        };
        loadModels = [
          # models deepseek
          "deepseek-r1:32b"
          "deepseek-coder:6.7b"
          "deepseek-coder:33b"
          "deepscaler:1.5b"
          "deepseek-r1:1.5b"
          "deepseek-r1:8b"
          "t1c/deepseek-math-7b-rl:Q4"
          # model OpenAI
          "gpt-oss:20b"
          "openchat:7b"
          "mapler/gpt2:latest"
          # model Meta
          "llama3.2:3b"
          # model Mistral
          "mathstral:7b"
          # models google
          "translategemma:4b"
          "bjoernb/gemma4-e2b-think:latest" 
          "gemma4:e4b"
          "gemma4:26b"
          "gemma3:12b"
          "translategemma:27b"
          # IBM models
          "ibm/granite4.0-preview:tiny-instruct-f16"
          # uncuncensored models
          "dolphin-mistral:7b"
          "wizardlm-uncensored:13b"
          "llama2-uncensored:7b"
          "dolphincoder:15b"
          "gurubot/gpt-oss-derestricted:20b"
          "aia/DeepSeek-R1-Distill-Qwen-32B-Uncensored-i1:latest"
          "thirdeyeai/DeepSeek-R1-Distill-Qwen-7B-uncensored:Q8_0"
        ];                  
        syncModels = true;
      };
    };

    systemd.services.ollama = {
      enable = true;
      environment = {
        LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
          stdenv.cc.cc.lib
          gfortran.cc.lib 
          linuxPackages.nvidia_x11 
        ];
      };
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        StateDirectory = "/var/lib/ollama";
        ReadWritePaths = [ "/var/lib/ollama" ]; 
        ProtectHome = lib.mkForce false;
      };
    };
  };
}