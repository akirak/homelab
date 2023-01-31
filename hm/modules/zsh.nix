{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh
    nix-zsh-completions
    fzy
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    history = {
      expireDuplicatesFirst = true;
      save = 5000;
      share = true;
      size = 5000;
    };

    # TODO: Add plugin inputs
    # plugins = [
    #   {
    #     name = "zsh-history-substring-search";
    #     src = pkgs.zsh-history-substring-search;
    #   }
    #   {
    #     name = "fzy";
    #     src = pkgs.zsh-fzy;
    #   }
    #   {
    #     name = "nix-shell";
    #     src = pkgs.zsh-nix-shell;
    #   }
    #   {
    #     name = "fast-syntax-highlighting";
    #     src = pkgs.zsh-fast-syntax-highlighting;
    #   }
    #   {
    #     name = "history-filter";
    #     src = pkgs.zsh-history-filter;
    #   }
    # ];

    sessionVariables = {
      "DIRSTACKSIZE" = "20";
      "NIX_BUILD_SHELL" = "zsh";
      # "VAGRANT_WSL_WINDOWS_ACCESS" = "1";
      # Set locale archives
      # https://github.com/NixOS/nixpkgs/issues/38991
      "LOCALE_ARCHIVE_2_11" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      "LOCALE_ARCHIVE_2_27" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      LANG = "en_GB.UTF-8";
      LANGUAGE = "en_US:zh_CN:zh_TW:en";
      LC_ALL = "C";
      LC_CTYPE = "en_GB";
      LC_MESSAGES = "en_GB";
      # Use ISO 8601 (YYYY-MM-DD) date format
      LC_TIME = "en_DK.UTF-8";
    };

    initExtra = ''
      setopt auto_cd
      setopt cdable_vars
      setopt auto_name_dirs
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt pushdminus

      # Configuration for zsh-fzy plugin https://github.com/aperezdc/zsh-fzy
      bindkey '\eq' fzy-proc-widget
      bindkey '\ew' fzy-cd-widget
      bindkey '\ee' fzy-file-widget
      bindkey '\er' fzy-history-widget
      zstyle :fzy:file command fd -t f
      zstyle :fzy:cd command fd -t d

      # Support directory tracking on emacs-libvterm.
      # https://github.com/akermu/emacs-libvterm#directory-tracking
      function chpwd() {
          print -Pn "\e]51;A$(pwd)\e\\";
      }

      # TODO: Add listEmacsProjects
      # function cd() {
      #   if [[ $# -gt 0 ]]
      #   then
      #     builtin cd "$@"
      #   else
      #     builtin cd "$({pkgs.listEmacsProjects}/bin/ls-emacs-projects --pipe fzy)"
      #   fi
      # }

      alias s='builtin cd "$(fd -t d | fzy)"'
      alias r='builtin cd "$(git rev-parse --show-toplevel)"'

      export NIX_BUILD_SHELL=bash

      export EDITOR=emacsclient

      # Use gpg-agent as ssh-agent.
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (pkgs.lib.fileContents ../etc/starship/starship.toml)
      }

      eval "$(${pkgs.starship}/bin/starship init zsh)"

      # https://github.com/MichaelAquilina/zsh-history-filter
      export HISTORY_FILTER_EXCLUDE=("TOKEN")
    '';
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      # "nvfetcher" = "nix run github:berberman/nvfetcher";
      ":h" = "run-help";
      # Drop these in favour of exa
      # "ls" = "ls --color=auto";
      # "la" = "ls -a";
      # "ll" = "ls -l";
      "rm" = "rm -i";
      "j" = "journalctl -xe";
      "start" = "systemctl --user start";
      "stop" = "systemctl --user stop";
      "enable" = "systemctl --user enable";
      "disable" = "systemctl --user disable";
      "reload" = "systemctl --user daemon-reload";
      "status" = "systemctl --user --full status";
      "restart" = "systemctl --user restart";
      "list-units" = "systemctl --user list-units";
      "list-unit-files" = "systemctl --user list-unit-files";
      "reset" = "systemctl --user reset-failed";
      "nsearch" = "nix search --no-update-lock-file nixpkgs";
      "npupgrade" = "nix profile upgrade $(nix profile list | fzy | cut -d' ' -f1)";
      "npremove" = "nix profile remove $(nix profile list | fzy | cut -d' ' -f1)";
    };
  };
}
