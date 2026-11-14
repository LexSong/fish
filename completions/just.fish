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

# Past a recipe name (`just link <TAB>`), add fish's own file/folder completion:
# just offers paths there too, but Windows-style (`..\lora-lab\`), which fish
# cannot continue from. Gated on the second token being a *known* recipe and not
# the token still being typed, so bare `just <TAB>` / `just li<TAB>` are unaffected.
complete -c just -F -n 'set -l t (commandline --current-process --tokenize --cut-at-cursor); \
    set -q t[2]; \
    and not string match -q -- "$t[2]" (commandline --current-token); \
    and contains -- $t[2] (just --summary 2>/dev/null | string split " ")'
