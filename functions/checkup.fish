function checkup --description 'Report missing project config (CLAUDE.md, ruff isort settings, Claude hook)'
    # Same script Claude Code runs at session start; it stays quiet when there is
    # nothing to say, which is confusing when you asked for it on purpose.
    set -l report (sh ~/windows-setup/scripts/project-checkup.sh $argv)
    if test -z "$report"
        echo 'nothing to report'
    else
        printf '%s\n' $report
    end
end
