# Shadows fish 4.8's bundled `just` completion, which is broken under MSYS2 fish:
# it invokes just through a Windows-style path resolved from the scoop shim
# (`JUST_COMPLETE=fish 'C:\Users\...\just.exe' -- …`), and fish refuses to run
# that -- "fish: Unknown command" -- so `just <TAB>` offers nothing at all.
# just's dynamic completion protocol itself is fine, so just call it by name.
#
# just is a native exe, so it ends a folder with `\` (`alpha\`), which fish
# cannot continue from. We change that last `\` to `/`. The pattern stops at the
# first tab, so a description is never changed.
function __just_candidates
    JUST_COMPLETE=fish just -- (commandline-words) 2>/dev/null |
        string replace -r '^([^\t]*)\\\\(\t|$)' '$1/$2'
end
complete -c just -f -a "(__just_candidates)"
