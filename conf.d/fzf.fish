status is-interactive; or return

# fzf ships its own fish integration, so we source it rather than keep a copy
# here. It binds ctrl-r, ctrl-t, alt-c, and shift-tab. fish runs conf.d before
# config.fish, so binds there win on any future conflict.
fzf --fish | source

# Every fzf widget reads this variable at run time, so one setting covers them
# all. `--cycle` lets ctrl-j/k/n/p wrap around past the ends of the list.
set -gx FZF_DEFAULT_OPTS --cycle

# Tab uses fzf's fuzzy picker too. `--select-1` inserts a unique match without
# showing the picker. Counting candidates in fish first would run completion
# twice, and warm `git checkout ` completion alone takes ~2.5s here.
# fzf_complete appends its arguments after its own `--multi`, and a later fzf
# option wins, so `--no-multi` keeps multi-select on shift-tab only. Without
# multi-select, tab is free inside the picker, so it accepts like enter.
bind tab 'fzf_complete --select-1 --no-multi --bind=tab:accept'
bind -M insert tab 'fzf_complete --select-1 --no-multi --bind=tab:accept'

# fzf is a native exe, so MSYS2 rewrites `--walker-root=/d/foo` into `D:/foo`,
# and the results come back as `D:/foo/...`. fish's cd rejects that form. These
# two widgets are copied from fzf 0.74.5; the only change is the `cygpath -u`
# that turns results back into `/d/foo/...`.
#
# We keep fzf's walker and convert only the results. A custom lister in
# FZF_CTRL_T_COMMAND would not help. MSYS2 `find` gives `/d/...` paths, but it
# is slow, because MSYS2 emulates POSIX file metadata on every file. `fd` is a
# native exe too, so it also returns `D:/...` paths.
function fzf-file-widget -d "List files and folders"
    set -l commandline (__fzf_parse_commandline)
    set -l dir $commandline[1]
    set -l fzf_query $commandline[2]
    set -l prefix $commandline[3]

    set -lx FZF_DEFAULT_OPTS (__fzf_defaults \
        "--reverse --walker=file,dir,follow,hidden --scheme=path" \
        "--multi $FZF_CTRL_T_OPTS --print0")

    set -lx FZF_DEFAULT_OPTS_FILE

    set -lx FZF_DEFAULT_COMMAND

    if test -n "$FZF_CTRL_T_COMMAND"
        set -f result (eval $FZF_CTRL_T_COMMAND \| (__fzfcmd) --query=$fzf_query | string split0)
    else
        set -f result (eval (__fzfcmd) --walker-root=$dir --query=$fzf_query | string split0)
    end

    test -n "$result"
    and set -f result (cygpath -u -- $result)
    and commandline -rt -- (string join -- ' ' $prefix(string escape -n -- $result))' '

    commandline -f repaint
end

function fzf-cd-widget -d "Change directory"
    set -l commandline (__fzf_parse_commandline)
    set -lx dir $commandline[1]
    set -l fzf_query $commandline[2]
    set -l prefix $commandline[3]

    set -lx FZF_DEFAULT_OPTS (__fzf_defaults \
        "--reverse --walker=dir,follow,hidden --scheme=path" \
        "$FZF_ALT_C_OPTS --no-multi --print0")

    set -lx FZF_DEFAULT_OPTS_FILE
    set -lx FZF_DEFAULT_COMMAND "$FZF_ALT_C_COMMAND"

    if set -l result (eval (__fzfcmd) --query=$fzf_query --walker-root=$dir | string split0)
        cd -- (cygpath -u -- $result)
        commandline -rt -- $prefix
    end

    commandline -f repaint
end
