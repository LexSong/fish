function pyproject --description 'Scaffold a Python project from the template in windows-setup'
    # The script lives in windows-setup (unlinked payload); this is its interface.
    sh ~/windows-setup/scripts/pyproject.sh $argv
end
