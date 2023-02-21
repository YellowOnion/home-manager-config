{ config, pkgs, ... }:

let bgLockImg = pkgs.runCommand "bg_locked.png" {} ''
    export HOME=./
    mkdir tmp
    export TMP=./tmp
    ${pkgs.gmic}/bin/gmic ${./bg.png} blur 5 rgb2hsv split c "${./bg_noise.png}" mul[-2,-1] sub[-2] 10% add[-1] 10% append[-3--1] c hsv2rgb output[-1] "$out"
'';
in
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
    (writeShellScriptBin "runVKGame"
      ''
      PIPEWIRE_NODE=game PULSE_SINK=game OBS_VKCAPTURE=1 MANGOHUD=1 "$@"
      '')
    (writeShellScriptBin "runOGLGame"
      ''
      PIPEWIRE_NODE=game PULSE_SINK=game obs-gamecapture mangohud "$@"
      '')
    #(writeShellScriptBin "runWithMouseLock"
    #  ''
    #    swaymsg 'input "Glorious Model O" map_to_output $primary_monitor'
    #    $@"
    #    swaymsg 'input "Glorious Model O" map_to_output *'
    #  '')
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

    "sway/config.d/bg_image" = {
      text = ''
          output * bg ${./bg.png} fill
          '';
    };

    "swaylock/config".text =
      ''
        daemonize
        color=333333
        image=${./bg_lock.png}
      '';
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
