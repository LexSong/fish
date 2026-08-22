function repo-status --description 'Report git status (dirty files, unpushed/unpulled commits) across my personal repos'
    # Mirrors the repos bootstrap.cmd clones -- keep the two lists in sync.
    set -l repos \
        ~/windows-setup \
        ~/windows-setup/dotfiles/windows-terminal-settings \
        ~/AppData/Local/nvim \
        ~/.config/fish \
        ~/.claude

    for repo in $repos
        test -d "$repo/.git"; or continue

        git -C "$repo" fetch --quiet
        echo (set_color --bold)(string replace -- "$HOME" '~' "$repo")(set_color normal)
        git -C "$repo" -c color.status=always status -sb
        echo
    end
end
