# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let  
  secrets = import ./secrets.nix;

  unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
  }) {};
in

{
  imports = [ 
    ./modules
    ./hardware-configuration.nix
  ];


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.dms-shell.enable = true;

  # programs.hyprland.settings = {
  #   decoration = {
  #     rounding = 12;
  #     active_opacity = 0.9;
  #     inactive_opacity = 0.8;
      
  #     blur = {
  #       enabled = true;
  #       size = 6;
  #       passes = 3;
  #       new_optimizations = true;
  #       ignore_opacity = true;
  #     };
  #   };

  #   general = {
  #     gaps_in = 6;
  #     gaps_out = 12;
  #     border_size = 2;
  #     "col.active_border" = "ee6246ff ee9646ff 45deg"; # Оранжево-красный градиент под Caelestia
  #     "col.inactive_border" = "rgba(595959aa)";
  #   };
  # };

  # Use the systemd-boot EFI boot loader.
  # boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.

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

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  # services.xserver.displayManager.lightdm.enable = true;
  services.xserver.enable = true;


  # ==== Bluetooth ====

  hardware.bluetooth.enable = true; # Включает поддержку Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Включает Bluetooth при загрузке

  services.blueman.enable = true;

  # services.pulseaudio.enable = true;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true; # Используется как менеджер сессий
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  /*ln -sfT /nix/ollamaModels/models /var/lib/ollama/models/*/
  system.activationScripts.restore = ''
    ln -sfT /nix/book\ and\ info /home/leshii/Books\ and\ info
    ln -sfT /nix/wine /home/leshii/.wine
    ln -sfT /nix/Steam /home/leshii/.local/share/Steam
    ln -sfT /nix/.steam /home/leshii/.steam
    ln -sfT /nix/config /home/leshii/.config
    ln -sfT /nix/.ssh /home/leshii/.ssh
    ln -sfT /nix/.ollama/ /var/lib/ollama
    ln -sfT /nix/.arduino/.arduino15 ~/.arduino15
    ln -sfT /nix/.arduino/.arduinoIDE /home/leshii/.arduinoIDE
    ln -sfT /nix/.arduino/Arduino /home/leshii/Arduino
    chown leshii /home/leshii -R
  '';
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.leshii = {
    initialPassword = secrets.sudoPassword;
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "audio" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  programs.niri.enable = true;
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  
  
  # ==== htop ====
  programs = {
    htop = {
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
  };  



  environment.systemPackages = with pkgs;  [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget

    throne
    nftables
    iptables


    mangohud
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

    htop
    fastfetch

    ruby
    dotnet-sdk
    wezterm
    jetbrains-mono
    
    scrcpy
    qpwgraph
    blender

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
    # Тема и иконки
    catppuccin-gtk
    catppuccin-kvantum
    papirus-icon-theme
      
    # Компоненты интерфейса
    waybar        # Стандартная и мощная панель
    awww          # Для обоев с анимацией
    swaynotificationcenter # Уведомления как на скриншоте
    rofi # Меню запуска приложений
  ];
  # 

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