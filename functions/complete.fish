# MSYS2 mounts drives with noacl, so Cygwin calls any file that starts with the
# PE magic `MZ` executable. fish lists every executable on PATH when it
# completes a command name, so every DLL on PATH shows up there, 3561 from
# System32 alone. fish has no filter for that list, and fzf_complete (our Tab)
# has no hook for the command name. It reads its candidates from
# `complete -C --escape -- LINE`, so we filter here.
#
# We drop `.dll` only when LINE is a single word, because then the cursor is on
# the command name, and a DLL there is never a command you can run. In an
# argument, fish lists files instead of PATH, so a `.dll` there is a real file.
# Counting spaces misses some command names, such as after `sudo`, but a miss
# only lets the DLLs show again.
function complete
    if contains -- -C $argv; and string match -qr -- '^\S*$' $argv[-1]
        builtin complete $argv | string match -rvi -- '\.dll(\t|$)'
        return
    end
    builtin complete $argv
end
