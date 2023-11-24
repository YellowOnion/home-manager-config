{
  description = "Home Manager configuration of daniel";

  inputs = {
    # keep synced with NixOS commit
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
     nix-straight = {
      url = "github:codingkoi/nix-straight.el?ref=codingkoi/apply-librephoenixs-fix";
      flake = false;
    };
    nix-doom-emacs = {
       url = "github:nix-community/nix-doom-emacs";
       inputs.nix-straight.follows = "nix-straight";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openttd = {
      url = "github:YellowOnion/nix-openttd-jgrpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, emacs-overlay, nix-doom-emacs, home-manager, openttd, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system;
                              config.allowUnfree = true;
                              overlays = [ (import emacs-overlay) ];
                            };
      mkHomeConf = file: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {openttd = import openttd {pkgs = pkgs;};};

        modules = [ nix-doom-emacs.hmModule file ];
      };

    in {
      homeConfigurations."daniel@Purple-Sunrise" = mkHomeConf ./purple.nix;
      homeConfigurations."daniel@Kawasaki-Lemon2" = mkHomeConf ./laptop.nix;
    };
}
