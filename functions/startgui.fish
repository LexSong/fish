function startgui --description 'Start a GUI app that does not hold this tab open: startgui PROGRAM [ARG...]'
    # A GUI started from fish inherits the console handles, so the tab stays open
    # until the GUI quits. ShellExecute passes no handles. Windows programs cannot
    # read MSYS2 paths, so an argument that is an existing path gets converted.
    set -l program (command -s $argv[1])
    or return
    set -l args
    for arg in $argv[2..]
        if test -e $arg
            set -a args (cygpath -aw -- $arg)
        else
            set -a args $arg
        end
    end
    rundll32 shell32.dll,ShellExec_RunDLL (cygpath -aw -- $program) $args
end
