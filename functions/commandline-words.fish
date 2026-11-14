# Print the words of the current command up to the cursor, one per line, for
# completion code. The last line is the word being typed, and it is an empty
# line when the cursor follows a space. The words before it are expanded, so
# `$HOME/a` arrives as `/c/Users/LexSong/a`. The word being typed is not.
#
# Arguments go to `commandline`, so a test can pass `--input=LINE`.
function commandline-words
    set -l word (commandline $argv --current-token)
    printf '%s\n' (commandline $argv --current-process --tokens-expanded --cut-at-cursor) "$word"
end
