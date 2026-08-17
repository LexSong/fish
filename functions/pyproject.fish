function pyproject --description 'Scaffold a Python project from the template in windows-setup'
    if test -e pyproject.toml
        echo 'pyproject.toml already exists' >&2
        return 1
    end
    # `/.` copies the template's dotfiles too (.claude/); -n never clobbers.
    cp -rn ~/windows-setup/pyproject-template/. .
end
