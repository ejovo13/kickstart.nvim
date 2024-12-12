--
--
--
-- Snippet string of a flake
--
--
local flakes = {}

flakes.basic = [[{
  description = "<<<<SNIPPET_EJOVO_NODE>>>>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
  in {
    packages.x86_64-linux.default = import ./default.nix {
      pkgs = pkgs;
    };
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [pkgs.ffmpeg pkgs.cmake pkgs.pcg_c pkgs.pkg-config];

      shellHook = ''
        fish -c echo "ffmpeg is available at $(which ffmpeg)"
      '';
    };
  };
}]]

flakes.documented = [[{self, ...} @ inputs: {
  # Executed by `nix flake check`
  checks."<system>"."<name>" = derivation;
  # Executed by `nix build .#<name>`
  packages."<system>"."<name>" = derivation;
  # Executed by `nix build .`
  packages."<system>".default = derivation;
  # Executed by `nix run .#<name>`
  apps."<system>"."<name>" = {
    type = "app";
    program = "<store-path>";
  };
  # Executed by `nix run . -- <args?>`
  apps."<system>".default = {
    type = "app";
    program = "...";
  };

  # Formatter (alejandra, nixfmt or nixpkgs-fmt)
  formatter."<system>" = derivation;
  # Used for nixpkgs packages, also accessible via `nix build .#<name>`
  legacyPackages."<system>"."<name>" = derivation;
  # Overlay, consumed by other flakes
  overlays."<name>" = final: prev: {};
  # Default overlay
  overlays.default = final: prev: {};
  # Nixos module, consumed by other flakes
  nixosModules."<name>" = {config, ...}: {
    options = {};
    config = {};
  };
  # Default module
  nixosModules.default = {config, ...}: {
    options = {};
    config = {};
  };
  # Used with `nixos-rebuild switch --flake .#<hostname>`
  # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
  nixosConfigurations."<hostname>" = {};
  # Used by `nix develop .#<name>`
  devShells."<system>"."<name>" = derivation;
  # Used by `nix develop`
  devShells."<system>".default = derivation;
  # Hydra build jobs
  hydraJobs."<attr>"."<system>" = derivation;
  # Used by `nix flake init -t <flake>#<name>`
  templates."<name>" = {
    path = "<store-path>";
    description = "template description goes here?";
  };
  # Used by `nix flake init -t <flake>`
  templates.default = {
    path = "<store-path>";
    description = "";
  };
}]]

flakes.package = [[{
{
  description = "<<<<SNIPPET_EJOVO_NODE>>>>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: 
  let
    pkgs = import nixpkgs {system = "x86_64-linux";};
  in {


    packages.x86_64-linux.default = pkgs.mkDerivation {
      <<<<SNIPPET_EJOVO_NODE>>>>
    };
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = []
      shellHook = ''
      '';
    };

    formatter.x86_64-linux.default = pkgs.alejandra;
  };
}]]

return flakes
