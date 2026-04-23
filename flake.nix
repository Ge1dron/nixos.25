{
  description = "NixOS configuration with Caelestia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    caelestia-shell.url = "github:caelestia-dots/shell";
    caelestia-cli.url   = "github:caelestia-dots/cli";
  };

  outputs = { self, nixpkgs, caelestia-shell, caelestia-cli, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      cshell = caelestia-shell.packages.${system}.default;
      ccli   = caelestia-cli.packages.${system}.default;
    in {
      nixosConfigurations.my-host = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./modules/caelestia.nix
        ];
        configuration = {
          # передаём пакеты через модуль или оставляем пустым
        };
      };
    };
}
