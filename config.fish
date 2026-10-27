set -gx LANG en_US.UTF-8

if status is-interactive
    bind ctrl-h backward-kill-word
end
