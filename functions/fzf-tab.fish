# Tab and shift-tab. fzf_complete asks fish to complete the word under the
# cursor, and then fzf can only filter that short list. So you must leave fzf to
# change the word. We clear the word first and pass it to fzf as the query, so
# fzf holds the full list and you edit the word there.
function fzf-tab
    set -l token "$(commandline -t)"
    # `--select-1` inserts a unique match without showing the picker. Counting
    # candidates in fish first would run completion twice, and warm
    # `git checkout ` completion alone takes ~2.9s here. `--nth=1` matches the
    # query against the candidate only, not its description.
    set -l opts --select-1 --nth=1 $argv
    set -l plan (fzf-tab-plan "$token" (commandline -pc --tokens-expanded))
    set -l source $plan[1]
    set -l query --query=$plan[3]

    commandline -rt -- $plan[2]
    set -l cleared "$(commandline)"
    if test $source = commands
        fzf-command-names | fzf_complete $opts $query
    else
        fzf_complete $opts $query
    end

    if test "$(commandline)" = "$cleared"
        # fzf_complete leaves the line alone on cancel, so we restore the word.
        commandline -rt -- "$token"
    else if string match -q -- '*= ' "$(commandline --cut-at-cursor)"
        # fzf_complete adds a space after the result. A result that ends with
        # `=` (`project=`, `--color=`) needs a value next, so we delete the space.
        commandline -f backward-delete-char
    end
end
