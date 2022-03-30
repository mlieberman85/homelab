{ config, lib, pkgs, ... }:
#Based on https://github.com/mitchellh/nixos-config/blob/main/users/mitchellh/home-manager.nix
 {
  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs; [
    bat
    git
    nixpkgs-fmt
    unzip
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = true;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    #initExtra = builtins.readFile ./bashrc;  
    initExtra = ''
      fish
    '';

    shellAliases = {
      rebuild="sudo nixos-rebuild switch -I nixos-config=$HOME/Projects/homelab/nixos/configuration.nix";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
 #     "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
 #     "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
 #     "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      #(builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

    shellAliases = {
      rebuild="sudo nixos-rebuild switch -I nixos-config=$HOME/Projects/homelab/nixos/configuration.nix";
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };
  };

  programs.git = {
    enable = true;
    userName = "Michael Lieberman";
    userEmail = "mlieberman85@gmail.com";
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "mlieberman85";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false
      bind -n C-k send-keys "clear"\; send-keys "Enter"
    '';
  };

  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      key_bindings = [
        { key = "K"; mods = "Command"; chars = "ClearHistory"; }
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Subtract"; mods = "Command"; action = "DecreaseFontSize"; }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    #extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  #xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  xsession.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };
}
