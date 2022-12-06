{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d;
    emacsPackage   = pkgs.emacsPgtkNativeComp;
  };

  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    url = https://github.com/nix-community/emacs-overlay/archive/7627a31cb49b9dfafe0ecf21ac2734374730d06a.tar.gz;
  #  }))
  #];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.packages = with pkgs; [
    rustc
    cargo
    rnix-lsp
    (writeShellScriptBin "discordToggleMute"
      ''
        xdotool key control+backslash
      '')
    (writeShellScriptBin "runGame"
      ''
      PULSE_SINK=game DXVK_HUD=fps obs-gamecapture "$@"
      '')
  ];

  programs.git = {
    enable = true;
    userName = "Daniel Hill";
    userEmail = "daniel@gluo.nz";
    extraConfig = {
      credential.helper = "store";
    };
  };

  programs.firefox = {
    enable = true;
    profiles."default".userChrome =
    ''#main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
        opacity: 0;
        pointer-events: none;
      }
      #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
      }'';
  };
  #home.service.emacs = {
  #  enabled = true;
  #  package = doom-emacs; };
  xdg.configFile = with pkgs; {
    "tmux/tmux.conf".text = lib.readFile ./tmux.conf;
    "sway/config".text = lib.readFile ./sway.conf;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
