{
  description = "Home Manager configuration of daniel";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #doom-emacs.url = "github:doomemacs/doomemacs/9d4d5b756a8598c4b5c842e9f1f33148af2af8fd";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    #nix-doom-emacs.inputs.doom-emacs.follows = "doom-emacs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, emacs-overlay, nix-doom-emacs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ (import emacs-overlay) ]; };
      mkHomeConf = file: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ nix-doom-emacs.hmModule file ];
      };

    in {
      homeConfigurations."daniel@Purple-Sunrise" = mkHomeConf ./purple.nix;
      homeConfigurations."daniel@Kawasaki-Lemon2" = mkHomeConf ./laptop.nix;
    };
}
