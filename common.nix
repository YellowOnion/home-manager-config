{ config, pkgs, openttd, ... }:

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
    # emacsPackage   = pkgs.emacsPgtk;
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.packages = with pkgs;
    let extraGameScripts = "${config.home.profileDirectory}/bin/extraGameScripts.sh";
        yad = "${pkgs.yad}/bin/yad";
    in
    [
      steamcmd
      rustc
      cargo
      rnix-lsp
      ffmpeg_5-full
      (writeShellScriptBin "discordToggleMute"
        ''
          xdotool key control+backslash
        '')
      (writeShellScriptBin "runVKGame"
        ''
        test -f ${extraGameScripts} && ${extraGameScripts}

        PIPEWIRE_NODE=game PULSE_SINK=game OBS_VKCAPTURE=1 MANGOHUD=1 systemd-inhibit "$@"
        '')
      (writeShellScriptBin "runOGLGame"
        ''
        test -f ${extraGameScripts} && ${extraGameScripts}
        PIPEWIRE_NODE=game PULSE_SINK=game systemd-inhibit obs-gamecapture mangohud "$@"
        '')
      #(writeShellScriptBin "runWithMouseLock"
      #  ''
      #    swaymsg 'input "Glorious Model O" map_to_output $primary_monitor'
      #    $@"
      #    swaymsg 'input "Glorious Model O" map_to_output *'
      #  '')

      (writeShellScriptBin "openttd-launcher"
        ''
        run_openttd () {
            cd $1
            ./bin/openttd
        }
        ${yad} --image ${openttd.vanilla}/share/icons/hicolor/128x128/apps/openttd.png \
               --text "Which Version of OpenTTD?" \
               --fixed \
               --buttons-layout=center \
               --button "Vanilla:0" \
               --button "JGR patch-pack:1" \
        && run_openttd ${openttd.vanilla} \
        || run_openttd ${openttd.jgr}
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
    "sway/config.d/home-manager"
      .text = ''
            exec_always $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
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
