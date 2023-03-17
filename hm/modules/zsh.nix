{pkgs, ...}: let
  listEmacsProjects = pkgs.writeShellScriptBin "ls-emacs-projects" ''
    set -euo pipefail

    while [[ $# -gt 0 ]]
    do
      case "$1" in
        # This option can be helpful in trivial shell functions where you don't
        # want to set separate `set -euo pipefail` option.
        --pipe)
          pipe="$2"
          shift
          ;;
      esac
      shift
    done

    # /tmp is protected, so use another directory
    tmp=$(mktemp -p "''${XDG_RUNTIME_DIR}")

    trap "rm -f '$tmp'" ERR EXIT

    # If the server isn't running, this script will exit with 1.
    emacsclient --eval "(with-temp-buffer
        (insert (mapconcat #'expand-file-name (project-known-project-roots) \"\n\"))
        (write-region (point-min) (point-max) \"$tmp\"))" > /dev/null

    if [[ -v pipe ]]
    then
      cat "$tmp" | $pipe
    else
      cat "$tmp"
    fi
  '';
in {
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

    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
      }
      {
        name = "fzy";
        src = pkgs.zsh-plugins.zsh-fzy;
      }
      {
        name = "nix-shell";
        src = pkgs.zsh-plugins.zsh-nix-shell;
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-plugins.zsh-fast-syntax-highlighting;
      }
      {
        name = "history-filter";
        src = pkgs.zsh-plugins.zsh-history-filter;
      }
    ];

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

      function cd() {
        if [[ $# -gt 0 ]]
        then
          builtin cd "$@"
        else
          builtin cd "$(${listEmacsProjects}/bin/ls-emacs-projects --pipe fzy)"
        fi
      }

      function clone() {
        if [[ $# -eq 0 ]]
        then
          echo "Usage: clone URL" >&2
          return 1
        else
          dir=''${$(emacsclient --eval "(expand-file-name (akirak-git-clone-dir \"$1\"))")//\"/}
          cd "$dir"
          echo "$dir"
        fi
      }

      function clock() {
        emacsclient -n --eval "(akirak-capture-clock-in
          (org-dog-complete-file \"Clock into file: \")
          \"$*\"
          :body (format \"[[file:%s]]\n%%?\" (abbreviate-file-name \"$PWD/\")))"
      }

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
      "s" = "builtin cd \"$(fd -t d | fzy)\"";
      "r" = "builtin cd \"$(git rev-parse --show-toplevel)\"";
      "e" = "emacsclient -n";
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
      "ssh-victim" = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
      "nsearch" = "nix search --no-update-lock-file nixpkgs";
      "npupgrade" = "nix profile upgrade $(nix profile list | fzy | cut -d' ' -f1)";
      "npremove" = "nix profile remove $(nix profile list | fzy | cut -d' ' -f1)";
    };
  };
}
