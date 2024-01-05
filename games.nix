{ config, lib, pkgs, ... }:

let
  cfg = config.games;
  vk-capture = pkgs.obs-studio-plugins.obs-vkcapture;

  withExtraGameScripts = scripts:
    (pkgs.writeShellScriptBin "run.sh"
      ''${
          let f = a: b: "exec ${a}/bin/run.sh " + b; in lib.foldr f ''"$@"'' scripts
        }
        '');

  gameScripts = withExtraGameScripts cfg.extraGameScripts;

  runVKGame = (pkgs.writeShellScriptBin "runVKGame"
    ''
      PIPEWIRE_NODE=game PULSE_SINK=game OBS_VKCAPTURE=1 MANGOHUD=1 systemd-inhibit ${gameScripts}/bin/run.sh "$@"
    '');

  runOGLGame = (pkgs.writeShellScriptBin "runOGLGame"
    ''
      PIPEWIRE_NODE=game PULSE_SINK=game systemd-inhibit ${vk-capture}/bin/obs-gamecapture mangohud ${gameScripts}/bin/run.sh "$@"
    '');
  withSwayFloating = (pkgs.writeShellScriptBin "withSwayFloating"
    ''
      ID=$(base64 /dev/urandom | head -c 8)
      ( kill -SIGSTOP $BASHPID; exec "$@" ) &
      PID=$!
      [ -z "$GAME_NAME" ] && GAME_NAME=$ID
      swaymsg "for_window [ pid = $PID ] mark --replace \"game:$GAME_NAME\""
      kill -SIGCONT $PID
      wait $PID
    '');
in
{
  options = {
    games = {
        extraGameScripts = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = lib.mdDoc "a list of extra scripts to run with a game";
      };
    };
  };
  config = lib.mkMerge [
    (
      {
        home.packages = [
          pkgs.jq
          runVKGame
          runOGLGame
          withSwayFloating
        ];
      }
    )
  ];
}
