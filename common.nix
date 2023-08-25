{ config, pkgs, openttd, ... }:

let bgLockImg = pkgs.runCommand "bg_locked.png" {} ''
    export HOME=./
    mkdir tmp
    export TMP=./tmp
    ${pkgs.gmic}/bin/gmic ${./bg.png} blur 5 rgb2hsv split c "${./bg_noise.png}" mul[-2,-1] sub[-2] 10% add[-1] 10% append[-3--1] c hsv2rgb output[-1] "$out"
'';
in
{
  manual.manpages.enable = false;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d;
    extraPackages = [pkgs.nil];
    # emacsPackage   = pkgs.emacsPgtk;
  };
  imports = [
    ./games.nix
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };
  home.packages = with pkgs;
    let
      extraGameScripts = "${config.home.profileDirectory}/bin/extraGameScripts.sh";
      wlrobs = obs-studio-plugins.wlrobs.overrideAttrs (a: {
        src = pkgs.fetchhg {
          url =  "https://hg.sr.ht/~scoopta/wlrobs";
          rev =  "f72d5cb3cbbd";
          sha256 = "1nf8pg45swjwacvdaraa6l7c24i95pqds3rbradllj8jgxvk88w6";
        };
        });
    in
    [
      nil
      steamcmd
      rustc
      cargo
      cachix
      ffmpeg_5-full
      imv
      unzip
      p7zip
      (wrapOBS {
        plugins = [ obs-studio-plugins.obs-vkcapture wlrobs ];
      })
      (writeShellScriptBin "discordToggleMute"
        ''
          xdotool key control+backslash
        '')
      (writeShellScriptBin "grimshot-area-better"
        ''
        OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
        FOCUS=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused).id')
        grim -t ppm -o $OUTPUT | imv -w screen-shot - &
        IMV_PID=$!
        grimshot --notify copy area
        imv-msg $IMV_PID=$! quit
        swaymsg "[con_id = $FOCUS] focus"
        ''
      )
      #(writeShellScriptBin "runWithMouseLock"
      #  ''
      #    swaymsg 'input "Glorious Model O" map_to_output $primary_monitor'
      #    $@"
      #    swaymsg 'input "Glorious Model O" map_to_output *'
      #  '')
      openttd.launcher
    ];

  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
  };

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
    "sway/config.d/home-manager"
      .text = ''
            exec_always $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
            seat seat0 xcursor_theme ${config.home.pointerCursor.name}
      '';

    "sway/config.d/bg_image"
      .text = ''
            output * bg ${./bg.png} fill
          '';

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
