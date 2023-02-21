{ config, pkgs, ... }:

let
  setDefaultMonitor = (pkgs.writeShellScriptBin
    "setDefaultMonitor"
    ''
      xrandr --output $( xrandr --listmonitors | grep "2560.*1440" | awk "{ print \$4 ; }" ) --primary
    '');
  swayResume = (pkgs.writeShellScriptBin
  "swayResume"
      ''
        swaymsg 'output * dpms on'
        sleep 1
        swaymsg 'output $lg mode 2560x1440@180hz'
        ${setDefaultMonitor}/bin/setDefaultMonitor
      '');
  proton-ge = pkgs.fetchzip (import ./proton.nix);
in
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    swayResume
    setDefaultMonitor
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = proton-ge;
  };

  xdg.configFile."sway/config.d/this"
    .text =
    ''
      exec ${setDefaultMonitor}/bin/setDefaultMonitor

      exec swayidle -w \
          timeout 605 'swaylock -f -c 000000' \
          timeout 600 'swaymsg "output * dpms off"' \
          resume ${swayResume}/bin/swayResume \
          before-sleep 'swaylock -f -c 000000'

      set $dell "Dell Inc. DELL P2314H D59H247SAGRL"
      set $lg   "LG Electronics LG ULTRAGEAR 203NTDV9B106"

      workspace 6 output $dell
      workspace 7 output $dell
      workspace 8 output $dell
      workspace 9 output $dell
      workspace 1 output $lg
      workspace 2 output $lg
      workspace 3 output $lg
      workspace 4 output $lg
      workspace 5 output $lg
      workspace 10 output $lg

      output $dell {
          transform 270
          pos 2560 0
      }

      output $lg {
          pos 0 0
          mode 2560x1440@180hz
      }

    input 1386:888:Wacom_Intuos_BT_M_Pen {
          map_to_output $lg
    }
    '';

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
