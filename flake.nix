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

    pkgs = import nixpkgs { inherit system; overlays = []; };
    lib = nixpkgs.lib;

    # guarded import of external Caelestia NixOS module (if file exists in the resolved flake)
    externalModulePath = caelestia-shell + "/nixos/module.nix";
    externalModule =
      if builtins.pathExists externalModulePath
      then import externalModulePath { inherit pkgs; }
      else null;

    # guarded import of external Caelestia package (try common paths; fallback null)
    tryImportPkg = path: let p = path; in if builtins.pathExists p then (import p { inherit pkgs; }) else null;
    caelestiaPkg =
      lib.foldl' (acc: p: acc or tryImportPkg p) null [
        (caelestia-cli + "/default.nix")
        (caelestia-cli + "/package.nix")
        (caelestia-cli + "/nix/default.nix")
      ];

    # small local module that installs the package (uses fallback if not found)
    localCaelestiaModule = { config, pkgs, lib, ... }: {
      options = { };
      config = {
        environment.systemPackages = lib.mkForce [
          (if caelestiaPkg != null then caelestiaPkg else pkgs.hello)
        ];
        # example service stub (replace ExecStart with real command if available)
        systemd.services.caelestia = {
          description = "Caelestia node (from flake input)";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.coreutils}/bin/true";
            Restart = "on-failure";
          };
        };
      };
    };
  in {
    nixosConfigurations = {
      my-host = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = lib.removeNulls [
          ./configuration.nix
          ./modules/caelestia.nix

          # include remote flake's NixOS module if present
          (if externalModule != null then externalModule else null)

          # include wrapper module that exposes caelestiaPkg (or fallback)
          localCaelestiaModule
        ];
      };
    };
  };
}
