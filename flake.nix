{
  description = "Home Manager configuration of daniel";

  inputs = {
    # keep synced with NixOS commit
    nixpkgs.url = "nixpkgs/bd645e8668ec6612439a9ee7e71f7eac4099d4f";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
     #nix-straight = {
     # url = "github:codingkoi/nix-straight.el?ref=codingkoi/apply-librephoenixs-fix";
     # flake = false;
    # };
    #nix-doom-emacs = {
    #   url = "github:nix-community/nix-doom-emacs";
    #   inputs.nix-straight.follows = "nix-straight";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #};
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openttd = {
      url = "github:YellowOnion/nix-openttd-jgrpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, emacs-overlay, home-manager, openttd, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system;
                              config.allowUnfree = true;
                              overlays = [ (import emacs-overlay) ];
                            };
      mkHomeConf = file: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {openttd = import openttd { pkgs = pkgs;};};

        modules = [ file ];
      };

    in {
      homeConfigurations."daniel@Purple-Sunrise" = mkHomeConf ./purple.nix;
      homeConfigurations."daniel@Kawasaki-Lemon" = mkHomeConf ./laptop.nix;
    };
}
