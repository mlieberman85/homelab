{ config, pkgs, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  imports = [ <home-manager/nix-darwin> ];
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  environment.systemPackages = with pkgs; [
    asciinema
    bat
    gh
    gitui
    go
    slack
    element-desktop
    mas
    rustup
    starship
    nodePackages.create-react-app
    nodejs
    yarn
    tmux
    jq
    ko
    syft
    bunyan-rs
    direnv
    htop
    helix
    zellij
    lsd
    ripgrep
    yazi
    zoxide
    fzf
    alacritty
    wezterm
    viu
    buf
    crane
    gdk
    awscli2
  ];

  fonts.packages = with pkgs; [ nerdfonts ];

  environment.systemPath = [ "/opt/homebrew/bin" ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [ "yabai" "skhd" "openssl" "llvm" "surreal" "colima" "protobuf" "gleam" "pkg-config" "cairo" "pango" "ttyd" "minder" "yq" "grpcurl" "cmake" "duckdb" "atlassian-plugin-sdk" "osv-scanner" "freerdp" "deno" ];
    casks =
      [ "visual-studio-code" "1password-cli" "font-hack-nerd-font" "warp" "alfred" ];
    taps = [ "koekeishiya/formulae" "surrealdb/tap" "homebrew/cask-fonts" "stacklok/tap" "atlassian/tap" ];
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true; # default shell on catalina
    enableSyntaxHighlighting = true;
    enableFzfHistory = true;
  };

  users.users.mlieberman = {
    name = "mlieberman";
    home = "/Users/mlieberman";
  };
  system.stateVersion = 4;
  nixpkgs.config.allowUnfree = true;
  home-manager.users.mlieberman = { pkgs, ... }: {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 18;
          normal = {
            font = "FiraCode Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            font = "FiraCode Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            font = "FiraCode Nerd Font Mono";
            style = "Italic";
          };
        };
      };
    };
    programs.nushell.enable = true;
    programs.zsh = {
      enable = true;
      initExtra = ''
        PATH=$PATH:/Users/mlieberman/.cargo/bin:/Users/mlieberman/.local/bin/:/Users/mlieberman/go/bin:/Users/mlieberman/.deno/bin
      '';
    };
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        return {
          font = wezterm.font 'FiraCode Nerd Font Mono',
          font_size = 16.0,
          color_scheme = "Tomorrow Night",
          front_end = "WebGpu"
        }
      '';
    };
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.helix = {
      enable = true;
      settings = {
        theme = "default";
        editor = {
          true-color = true;
          lsp.display-messages = true;
        };
      };
      # defaultEditor = true;
      languages = {
        language = [
          {
            name = "rust";
            auto-format = true;
          }
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          }
        ];
      };
    };
    programs.neovim = {
      enable = true;
      # package = pkgs.neovim-nightly;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      plugins = with pkgs;
        let
        in [ 
          vimPlugins.vim-nix
          vimPlugins.gruvbox-community
          vimPlugins.nvim-tree-lua
          vimPlugins.nvim-web-devicons 
          vimPlugins.gruvbox-material
          vimPlugins.plenary-nvim
          vimPlugins.mini-nvim
          vimPlugins.nvim-lspconfig
          vimPlugins.nvim-treesitter.withAllGrammars
        ];
        extraLuaConfig = /* lua */ ''
          vim.o.termguicolors = true
          vim.cmd('colorscheme gruvbox-material')
          vim.g.gruvbox_material_background = 'hard'
        '';
    };
    home.stateVersion = "24.11";
  };
}
