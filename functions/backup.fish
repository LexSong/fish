function backup --description 'Back up D: to the F: repo (elevates; VSS needs admin)'
    # sudo is a Windows exe: it resolves restic.exe off PATH and never sees the
    # `restic` function above, so the repo and password flags are repeated here.
    # It also runs with input disabled, which is why the password cannot be a prompt.
    set -l target /d/
    if set -q argv[1]
        set target $argv
    end
    sudo restic -r /f/restic-archives --password-command 'cmd /c echo restic' \
        backup $target --use-fs-snapshot --exclude-caches \
        --exclude '$RECYCLE.BIN' --skip-if-unchanged
end
