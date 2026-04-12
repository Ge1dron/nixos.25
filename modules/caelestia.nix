{ config, pkgs, lib, ... }:

# This module is intentionally minimal: it can be used to add extra config
# for Caelestia or override the service defined in flake.nix.
{
  options.caelestia.enable = lib.mkEnableOption "Enable Caelestia service";

  config = lib.mkIf config.caelestia.enable {
    # If the flake-provided service exists, it will be enabled by the service's wantedBy.
    # You can add extra mounts, users, or config here.
    systemd.services.caelestia.wantedBy = [ "multi-user.target" ];
  };
}
