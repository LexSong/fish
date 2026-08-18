function restic --description 'restic against the F: repo, password supplied'
    # `command` keeps this from recursing into itself. Covers the unelevated
    # calls -- snapshots, forget, check, restore; `backup` needs admin for VSS.
    command restic -r /f/restic-archives --password-command 'cmd /c echo restic' $argv
end
