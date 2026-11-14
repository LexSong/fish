# /// script
# requires-python = ">=3.12"
# dependencies = ["pytest"]
# ///
"""Test what Tab decides and offers, with no console and no picker.

Run: uv run tests/test_fzf_tab.py

`commandline --input` reads a line without a console, and `fzf --filter` prints
its matches without a picker. The reference for what Tab must offer is the old
Tab, which is `complete -C LINE`. These tests do not touch the real command line.
"""

import sys

import pytest
from test_fzf_command_names import login_fish

# fish checks each variable's value for a folder, and on this Claude Code named
# pipe that check takes 30s. The variable exists only under Claude Code.
READ_LINE = r"""
set -e CLAUDE_CODE_MESSAGING_SOCKET
set -l words (commandline-words --input=$line)
set -l word $words[-1]
set -l before $words[1..-2]
set -l plan (fzf-tab-plan "$word" $before)
"""

PRINT_PLAN = r"""
printf '%s\n' $plan
"""

PRINT_OLD_AND_NEW = r"""
complete -C --escape -- $line | string replace -r '\t.*' ''
echo ---
switch $plan[1]
    case commands
        fzf-command-names | fzf --filter=$plan[3] --nth=1
    case complete
        complete -C --escape -- (string join ' ' -- $before "$plan[2]") |
            fzf --filter=$plan[3] --delimiter=\t --nth=1 |
            string replace -r '\t.*' ''
end
true
"""


def run(line: str, body: str) -> list[str]:
    quoted = line.replace("\\", "\\\\").replace("'", "\\'")
    return login_fish(f"set -l line '{quoted}'" + READ_LINE + body)


def offered(line: str) -> tuple[list[str], list[str]]:
    """Return what the old Tab offers and what the new Tab offers, best first."""
    output = run(line, PRINT_OLD_AND_NEW)
    marker = output.index("---")
    return output[:marker], output[marker + 1 :]


@pytest.mark.parametrize(
    ("line", "expected"),
    [
        # The query is the letters, digits, `_`, `-` and `.` at the end of the word.
        ("git ck", ("complete", "", "ck")),
        ("git ", ("complete", "", "")),
        ("git sparse-ch", ("complete", "", "sparse-ch")),
        ("ls a_b", ("complete", "", "a_b")),
        ("ls conf.d", ("complete", "", "conf.d")),
        ("ls fzf-tab.fi", ("complete", "", "fzf-tab.fi")),
        # Everything before it stays.
        ("ls conf.d/fz", ("complete", "conf.d/", "fz")),
        ("ls a/b/c", ("complete", "a/b/", "c")),
        ("ls ~/", ("complete", "~/", "")),
        ("rg --color=al", ("complete", "--color=", "al")),
        ("dd if=/de", ("complete", "if=/", "de")),
        ("ls w*", ("complete", "w*", "")),
        ("ls conf.d/w*", ("complete", "conf.d/w*", "")),
        ('ls "a b', ("complete", '"a ', "b")),
        ("ls 'a", ("complete", "'", "a")),
        ("ls $HOME/a", ("complete", "$HOME/", "a")),
        # A leading `.` also keeps one `.`.
        ("ls .g", ("complete", ".", ".g")),
        ("ls ~/.con", ("complete", "~/.", ".con")),
        ("ls ..", ("complete", ".", "..")),
        # A leading `-` also keeps one `-`.
        ("git log --ab", ("complete", "-", "--ab")),
        ("git log -", ("complete", "-", "-")),
        ("git log --abbrev-com", ("complete", "-", "--abbrev-com")),
        # Variables: `$` splits the word, like any other character.
        ("echo $PA", ("complete", "$", "PA")),
        ("echo $", ("complete", "$", "")),
        ("echo $AI_AG", ("complete", "$", "AI_AG")),
        ("rg --file=$PA", ("complete", "--file=$", "PA")),
        # Command names.
        ("", ("commands", "", "")),
        ("gi", ("commands", "", "gi")),
        ("git-f", ("commands", "", "git-f")),
        ("fish_ad", ("commands", "", "fish_ad")),
        ("echo a | gi", ("commands", "", "gi")),
        ("echo a; gi", ("commands", "", "gi")),
        # Anything before the word leaves it to fish.
        ("./fo", ("complete", "./", "fo")),
        ("sudo gi", ("complete", "", "gi")),
        ("and gi", ("complete", "", "gi")),
        ("not time gi", ("complete", "", "gi")),
    ],
)
def test_plan(line, expected):
    assert tuple(run(line, PRINT_PLAN)) == expected


@pytest.mark.parametrize(
    "line",
    [
        "git ",
        "git ck",
        "git co",
        "git sparse-ch",
        "git checkout ma",
        "git log -",
        "git log --ab",
        "git log --abbrev-com",
        "git log --format=",
        "ls ",
        "ls nf.d",
        "ls conf.d",
        "ls config.fi",
        "ls conf.d/",
        "ls conf.d/fz",
        "ls .g",
        "ls ~/.con",
        "ls .",
        "ls ..",
        "ls conf.d/.",
        ".g",
        "cd .g",
        "cd co",
        "cd conf.d/",
        "dd if=/de",
        "env FOO=ba",
        "just ",
        "uv r",
        "uv run --",
        "rg --color=a",
        "rg --file=$PA",
        "echo $",
        "echo $PA",
        "echo $AI_AG",
        "sudo gi",
        "gi",
        "git-f",
        "fish_ad",
        "and gi",
        "echo a | gi",
        "./",
    ],
)
def test_new_tab_offers_all_that_the_old_tab_offered(line):
    old, new = offered(line)
    assert set(old) - set(new) == set()


@pytest.mark.parametrize(
    ("line", "name"),
    [
        # fish returns only commit, config and count-objects for `git co`.
        ("git co", "checkout"),
        ("git chk", "checkout"),
    ],
)
def test_new_tab_offers_what_the_old_tab_hid(line, name):
    _, new = offered(line)
    assert name in new


@pytest.mark.parametrize(
    ("line", "best"),
    [
        ("git ck", "checkout"),
        ("git checkout ma", "main"),
        ("git log --ab", "--abbrev"),
        ("ls conf.d/fz", "conf.d/fzf.fish"),
        ("git-filter-rep", "git-filter-repo"),
    ],
)
def test_best_match_comes_first(line, best):
    _, new = offered(line)
    assert new[0] == best


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q", "-p", "no:cacheprovider"]))
