set -gx LANG en_US.UTF-8

if status is-interactive
    # fzf ships its own fish integration, so we source it rather than keep a
    # copy here. It binds ctrl-r, ctrl-t, alt-c, and shift-tab. Our own binds
    # come after, so they win on any future conflict.
    fzf --fish | source

    bind ctrl-h backward-kill-word
end
