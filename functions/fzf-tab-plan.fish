# Decide what Tab does with a word, for fzf-tab. A key binding only runs in an
# interactive fish, so this logic stays here, where a test can call it directly.
#
# Usage: fzf-tab-plan WORD [TOKENS BEFORE WORD...]
# Prints 3 lines:
# - the list source: commands or complete
# - the part of the word that stays on the command line
# - the part of the word that goes to the fzf query
#
# We do not parse the word as fish does. The query is the letters, digits, `_`,
# `-` and `.` at its end, and the rest stays on the command line for fish to read.
function fzf-tab-plan -a token
    set -l before $argv[2..]
    set -l query (string match -r -- '[[:alnum:]_.-]*$' "$token")
    set -l fixed (string replace -r -- '[[:alnum:]_.-]*$' '' "$token")

    # fish lists options only for a name that starts with `-`, and hidden files
    # only for a name that starts with `.`, so that one character also stays. fzf
    # still matches the whole name, so `--ab` finds `--abbrev`.
    if string match -qr -- '^[-.]' "$query"
        set fixed "$fixed"(string sub -l 1 -- "$query")
    end

    # A word with no fixed part and nothing before it is a command name.
    if test -z "$fixed"; and test (count $before) -eq 0
        printf '%s\n' commands '' "$query"
        return
    end
    printf '%s\n' complete "$fixed" "$query"
end
