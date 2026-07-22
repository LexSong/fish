# Autoload stub so fish loads completions when `sbx` (not just `sbx.exe`) is
# tab-completed first in a session. The real logic lives in sbx.exe.fish,
# which only registers the literal `sbx.exe` command name.
source (status dirname)/sbx.exe.fish

# Register the same completions for the bare command name `sbx`.
# (MSYS2/Windows resolves `sbx` to `sbx.exe` automatically, but fish's
# `complete -c` matching is on the literal typed command name, so `sbx`
# needs its own registration reusing the helper functions from sbx.exe.fish.)
if type -q "sbx"
    complete --do-complete "sbx " > /dev/null 2>&1
end

complete -c sbx -e

complete -c sbx -n '__sbx.exe_clear_perform_completion_once_result'
complete -c sbx -n 'not __sbx.exe_requires_order_preservation && __sbx.exe_prepare_completions' -f -a '$__sbx_exe_comp_results'
complete -k -c sbx -n '__sbx.exe_requires_order_preservation && __sbx.exe_prepare_completions' -f -a '$__sbx_exe_comp_results'
