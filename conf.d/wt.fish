status is-interactive; or return
set -q WT_SESSION; or return

# Windows Terminal's duplicate tab (ctrl+shift+d) and duplicate pane
# (alt+shift+d) start in the directory the shell last reported with OSC 9;9.
# Windows Terminal needs a Windows path, so cygpath converts the MSYS path.
# cygpath is a separate process, so we report on each cd, not on each prompt.
# fish runs conf.d before /etc/fish/config.fish, which puts /usr/bin on PATH,
# so the first call needs cygpath's full path.
# Inside fish single quotes `\\` is one backslash, so printf needs `\\\\` to
# print the `\` that ends the sequence.
function __wt_report_cwd --on-variable PWD
    printf '\e]9;9;%s\e\\\\' (/usr/bin/cygpath -w -- $PWD)
end
__wt_report_cwd
