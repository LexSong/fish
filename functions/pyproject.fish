function pyproject --description 'Copy the pyproject.toml template into the current directory'
    if test -e pyproject.toml
        echo 'pyproject.toml already exists' >&2
        return 1
    end
    cp ~/windows-setup/pyproject.toml.template pyproject.toml
end
