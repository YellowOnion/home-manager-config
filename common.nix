{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.packages = with pkgs; [
    rustc
    cargo
    rnix-lsp
    (pkgs.writeShellScriptBin "testScript"
      ''
        echo "blah"
      '')
  ];
  programs.git = {
    enable = true;
    userName = "Daniel Hill";
    userEmail = "daniel@gluo.nz";
    extraConfig = {
      credential.helper = "store";
      core.excludesfile = "~/.gitignore_global";
    };
  };

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
