{ config, pkgs, ... }: {
  
    programs.home-manager.enable = true;
    home.stateVersion = "22.11";


    programs.vscode = {
        enable = true;
        mutableExtensionsDir = true;
        package = pkgs.vscode;

        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = with pkgs.vscode-extensions; [
            rust-lang.rust-analyzer
            jdinhlife.gruvbox
            arrterian.nix-env-selector
            jnoortheen.nix-ide
            redhat.java
        ];
        
        
        userSettings = {
            "editor.fontFamily" = "JetBrainsMono Nerd Font";
            "files.autoSave" = "afterDelay";
            "window.titleBarStyle" = "custom";
            "workbench.colorTheme" = "Gruvbox Dark Hard";
            "java.jdt.ls.java.home" = "${pkgs.jdk}/lib/openjdk";
        };
    };

    programs.neovim = {
        enable = true;
    };

    programs.starship = {
        enable = true;
    };

    programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;

        plugins = [
        {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
            };
        }
        ];

        oh-my-zsh = {
            enable = true;
            plugins = [
                "git"
                "docker"
            ];
        };

        initExtra = ''
        unsetopt BEEP
        eval "$(starship init zsh)"
        '';

        shellAliases = {
            ls = "exa --icons";
            la = "exa --icons --all";
        };
    };

    programs.alacritty = {
        enable = true;
    };

    gtk = {
        enable = true;

        theme = {
            name = "nordic";
            package = pkgs.nordic;
        };

        gtk3.extraConfig = {
            Settings = ''
                gtk-application-prefer-dark-theme=1
            '';
        };

        gtk4.extraConfig = {
            Settings = ''
                gtk-application-prefer-dark-theme=1
            '';
        };
    };
    home.sessionVariables.GTK_THEME = "nordic";


}
