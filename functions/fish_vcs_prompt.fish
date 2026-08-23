# Prompt redraws stay instant. Launching a native Windows exe from MSYS2 costs
# ~110ms, and fish's stock git prompt spawns four of them per redraw, so the
# branch is read straight out of .git/HEAD using only builtins. Fish's hg and
# svn support goes with it; nothing here uses them.
function fish_vcs_prompt --description 'Git branch from .git/HEAD, no subprocess'
    set -l dir $PWD
    while test -n "$dir"; and test "$dir" != /
        if test -e "$dir/.git"
            # A worktree or submodule makes .git a file pointing elsewhere, and
            # resolving that needs git itself, so show nothing rather than walk
            # up and report an enclosing repo's branch.
            if test -f "$dir/.git/HEAD"
                read -l head <"$dir/.git/HEAD"
                if string match -qr '^ref: refs/heads/(?<branch>.*)' -- $head
                    printf ' (%s)' $branch
                else
                    printf ' (%s)' (string sub -l 7 -- $head)
                end
            end
            return
        end
        set dir (path dirname "$dir")
    end
end
