if status is-interactive
    # freshfetch | lolcat
end

alias l "eza -lag --sort=type"
alias lt "eza --tree"

function h
    if test -n "$argv"
        hx $argv
    else
        hx (fzf)
    end
end

function nsync
    set initial_dir $PWD

    echo "Updating..."
    cd $HOME/.nixos_config_notebook/
    git pull

    echo "Copying..."
    cp -r $HOME/.nixos_config_notebook/ $HOME/.nixos_config_notebook_without_git

    echo "Changing to copy directory..."
    cd $HOME/.nixos_config_notebook_without_git || return # Exit if cd fails

    echo "Removing .git"
    rm -rf .git/

    echo "Rebuilding..."
    doas nixos-rebuild switch --flake .#

    echo "Removing copy..."
    rm -rf $HOME/.nixos_config_notebook_without_git/

    echo "Moving back to initial directory..."
    cd $initial_dir
end

fish_add_path $HOME/.cargo/bin/

set fish_greeting

# Starship Prompt
function starship_transient_prompt_func
    starship module character
end
starship init fish | source
enable_transience

zoxide init fish | source
