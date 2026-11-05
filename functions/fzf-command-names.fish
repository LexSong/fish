# List what can run as a command, for fzf-tab. `complete -C ''` takes ~820ms,
# because it checks every one of the 6900 files on PATH for executability.
# We trust `.exe` and `.com` by name in every folder. Only the folders below hold
# executables without an extension: every MSYS2 folder on PATH, and four
# Windows folders named below. We check ~200 files there. All other extensions
# are dropped by name, such as `.dll` and `.sys`.
# tests/test_fzf_command_names.py lists every difference from fish, and it fails
# when a new folder needs to go in this list.
function fzf-command-names
    # MSYS2 shows one folder as both /bin and /usr/bin.
    set -l path_folders (string match -v -- /bin $PATH)
    # A glob is case-sensitive, and System32 has PING.EXE.
    set -l exes $path_folders/*.exe $path_folders/*.EXE $path_folders/*.com
    # A Windows folder starts with a drive letter, as in /c/Users.
    set -l msys2_folders (string match -rv -- '^/[a-z]/' $path_folders)
    # The Windows folders that hold scripts, known by name.
    set -l scripts $msys2_folders/* \
        ~/windows-setup/bin/* \
        ~/scoop/shims/* \
        ~/scoop/apps/nodejs/current/* \
        ~/scoop/apps/nodejs/current/bin/*
    set -l dirs */
    begin
        builtin -n | string match -v -- .
        functions -n
        printf '%s\n' $exes
        path filter -fx -- (string match -rv -- '\.[^/]*$' $scripts)
    end | string replace -r '.*/' '' | string replace -ri '\.exe$' '' | path sort -u | string escape -n
    string escape -n -- $dirs
end
