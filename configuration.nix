# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let  
  secrets = import ./secrets.nix;

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
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
    networking.networkmanager.ensureProfiles.profiles = {
    
    "Home-WiFi" = {
      connection = { id = "Home-WiFi"; type = "wifi"; };
      wifi = { 
        ssid = secrets.homeSsid; 
      };
      wifi-security = { 
        key-mgmt = "wpa-psk"; 
        psk = secrets.homePass; 
      };
    };

    "Work-WiFi" = {
      connection = { id = "Work-WiFi"; type = "wifi"; };
      wifi = { ssid = secrets.workSsid; };
      wifi-security = { key-mgmt = "wpa-eap"; };
      "802-1x" = {
        eap = "peap";
        identity = secrets.workLogin;
        password = secrets.workPass;
        phase2-auth = "mschapv2";
      };
    };
  };

  
  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # ==== GRUB ====

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      
      theme = "${kawaiiGrubTheme}/kawaii-grub-theme";
      font = "${kawaiiGrubTheme}/kawaii-grub-theme/terminus-12.pf2";

      gfxmodeEfi = "1920x1080"; 
      gfxpayloadEfi = "keep"; 

      extraConfig = ''
        insmod all_video
        insmod gfxterm
        insmod png
        insmod jpeg
        insmod ext2
        
        search --set=root --file /nix/store/84xaqbisw1g9qb2fac8ygm8fq4xq0rcz-kawaii-grub-latest/kawaii-grub-theme/theme.txt

        terminal_output gfxterm
        
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
    };
  };

  # ==== proxy client ====
  programs = {
    throne.enable = true;
    throne.tunMode.enable = true;
  };
  
  services.resolved.enable = true;

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  # === Steam ===
  # services.xserver.displayManager.lightdm.enable = true;
  services.xserver.enable = true;
  programs.steam.gamescopeSession.enable = false;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };


  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet";
  };


  # ==== Bluetooth ====

  hardware.bluetooth.enable = true; # Включает поддержку Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Включает Bluetooth при загрузке

  services.blueman.enable = true;

  # === NVIDIA CONFIGURATION FOR LAPTOP ===
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfree = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

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
  # === END OF NVIDIA CONFIGURATION ===



    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable sound.
    # services.pulseaudio.enable = true;
    # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  /*ln -sfT /nix/ollamaModels/models /var/lib/ollama/models/*/
  system.activationScripts.restore = ''
    ln -sfT /nix/book\ and\ info /home/leshii/Books\ and\ info
    ln -sfT /nix/Steam /home/leshii/.local/share/Steam
    ln -sfT /nix/.steam /home/leshii/.steam
    ln -sfT /nix/config /home/leshii/.config
    ln -sfT /nix/.ssh /home/leshii/.ssh
    ln -sfT /nix/.ollama/ /home/leshii/.ollama
    chown leshii /home/leshii -R
  '';
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.leshii = {
    initialPassword = secrets.sudoPassword;
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "audio"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.email = "shishkov.dimentr@inbox.ru";
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
  programs.niri.enable = true;
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ==== Ollama and Local AI ====
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    home = "/home/leshii/.ollama";
    loadModels = [
      # models deepseek
      "deepscaler:1.5b"
      "deepseek-r1:1.5b"
      "deepseek-r1:8b"
      # model OpenAI
      "gpt-oss:20b"
      "openchat:7b"
      # model Meta
      "llama3.2:3b"
      # model Mistral
      "mathstral:7b"
      # models google
      "translategemma:4b"
      "gemma4:e4b" 
      # uncuncensored models
      "dolphin-mistral:7b"
      "wizardlm-uncensored:13b"
      "llama2-uncensored:7b"
      "dolphincoder:15b"
    ];                  
    syncModels = false;
  };

  systemd.services.ollama = {
    enable = true;
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "leshii";
      WorkingDirectory = "/home/leshii/.ollama";
      ReadWritePaths = [ "/home/leshii/.ollama" "/home/leshii/.ollama/models" ];
      ProtectHome = lib.mkForce false;
    };
  };


  # ==== htop ====

  programs.htop = {
    enable = true;
    settings = {
      show_program_path = true;
      hide_threads = true;
      hide_kernel_threads = true;
      delay = 15;

      show_cpu_temperature = true;
      show_gpu_temperature = true;
      show_cpu_frequency = true;
      show_gpu_frequency = true;

      left_meters = [ "LeftCPUs2" "Memory" "Swap" "DiskIO" "Tasks" "LoadAverage" "GPUTemperature"];
      right_meters = [ "RightCPUs2" "GPU" "Tasks" "LoadAverage" "CPUTemperature" ];
    };
  };

  # ==== Visual Studio Code ==== 
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      yzhang.markdown-all-in-one
      bbenoist.nix
      xaver.clang-format
      fortran-lang.linter-gfortran
      bierner.github-markdown-preview
      ms-vscode.hexeditor
      ms-vscode.cpptools
    ];
  };

  environment.systemPackages = with pkgs;  [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget

    nekoray
    nftables
    iptables

    # wine
    wineWowPackages.stable
    wine64
    libkrb5
    winetricks
    wineWowPackages.waylandFull
    samba
    krb5

    # PCB
    qucs-s
    kicad

    libreoffice

    kdePackages.bluez-qt      # Библиотека для связи Plasma с Bluetooth
    kdePackages.bluedevil     # Сам апплет Bluetooth
    alacritty
    fuzzel


    telegram-desktop
    discord

    nodejs_24

    # Компиляторы и среды для матана
    gfortran13
    octave

    # Компиляторы для низкого уровня программирования
    gdb
    gcc
    avra
    arduino-ide
    arduino-cli

    # Веб разработка
    hugo
    go
    caddy
    xray
    nix-ld
    htop

    ruby
    dotnet-sdk
    wezterm
    jetbrains-mono
    
    scrcpy
    qpwgraph
    blender

    steam
    gamescope

    # KDE
    kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kclock # Clock app
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdiff3 # Compares and merges 2 or 3 files or directories
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
    # Non-KDE graphical packages
    hardinfo2 # System information and benchmarks for Linux systems
    vlc # Cross-platform media player and streaming server
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland
 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  programs.mtr.enable = true;
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}