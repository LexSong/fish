# /// script
# requires-python = ">=3.12"
# dependencies = ["pytest"]
# ///
"""Test what Tab offers in a `just` command, with no console and no picker.

Run: uv run tests/test_just_completion.py

Each test states one thing we expect completions/just.fish to do. The tests
cover only the cases known to work. They run in a temporary folder that holds:

    justfile     variable `project`, recipe `run`
    alpha/sub/
    beta/
    notes.txt

`complete -C LINE` gives the list that Tab offers for LINE, and fzf-tab sends
the same list to fzf.
"""

import sys
from pathlib import Path

import pytest
from test_fzf_command_names import login_fish

JUSTFILE = """\
project := "alpha"

run target="x":
    echo {{project}} {{target}}
"""

# fish checks each variable's value for a folder, and on this Claude Code named
# pipe that check takes 30s. The variable exists only under Claude Code.
#
SETUP = r"""
set -e CLAUDE_CODE_MESSAGING_SOCKET
cd '{folder}'
set -l line '{line}'
"""

# `string replace` returns 1 when it changes no line, and login_fish treats that
# as a failure, so the script ends with `true`.
PRINT_CANDIDATES = r"""
complete -C -- $line | string replace -r '\t.*' ''
true
"""

PRINT_WORDS = r"""
commandline-words --input=$line | string replace -r '^(.*)$' '[$1]'
"""


@pytest.fixture
def folder(tmp_path: Path) -> str:
    """Build the test folder, and return its path in the form fish reads."""
    (tmp_path / "justfile").write_text(JUSTFILE, encoding="utf-8")
    (tmp_path / "alpha" / "sub").mkdir(parents=True)
    (tmp_path / "beta").mkdir()
    (tmp_path / "notes.txt").write_text("", encoding="utf-8")
    return "/" + tmp_path.as_posix().replace(":", "", 1)


def run(folder: str, line: str, body: str) -> list[str]:
    return login_fish(SETUP.format(folder=folder, line=line) + body)


def offered(folder: str, line: str) -> list[str]:
    """Return the candidates for the line, without options and descriptions."""
    candidates = run(folder, line, PRINT_CANDIDATES)
    return [name for name in candidates if not name.startswith("-")]


def test_first_word_offers_recipes_and_variables(folder):
    """`just <TAB>` offers the recipe `run` and the variable `project=`."""
    names = offered(folder, "just ")
    assert "run" in names
    assert "project=" in names


def test_half_typed_recipe_is_completed(folder):
    """`just ru<TAB>` offers only the recipe `run`."""
    assert offered(folder, "just ru") == ["run"]


def test_folders_end_with_a_slash(folder):
    """just prints a folder as `alpha\\`. We offer `alpha/`, and no `\\` at all."""
    names = offered(folder, "just ")
    assert "alpha/" in names
    assert "beta/" in names
    assert [name for name in names if "\\" in name] == []


def test_variable_override_offers_paths(folder):
    """`just project=<TAB>` offers every file and folder, after the `project=`."""
    assert set(offered(folder, "just project=")) == {
        "project=alpha/",
        "project=beta/",
        "project=justfile",
        "project=notes.txt",
    }


def test_variable_override_completes_a_half_typed_path(folder):
    """`just project=al<TAB>` offers only the folder that starts with `al`."""
    assert offered(folder, "just project=al") == ["project=alpha/"]


def test_variable_override_goes_into_a_folder(folder):
    """`just project=alpha/<TAB>` offers what the folder `alpha` holds."""
    assert offered(folder, "just project=alpha/") == ["project=alpha/sub/"]


def test_after_a_variable_override_the_recipes_are_offered(folder):
    """`just project=alpha <TAB>` still offers the recipe `run`."""
    assert "run" in offered(folder, "just project=alpha ")


def test_recipe_argument_offers_the_folders(folder):
    """`just run <TAB>` offers the folders that just lists, each ending in `/`."""
    names = offered(folder, "just run ")
    assert "alpha/" in names
    assert "beta/" in names


def test_recipe_argument_goes_into_a_folder(folder):
    """`just run alpha/<TAB>` offers what the folder `alpha` holds. just lists
    it, so this works without fish's own file completion."""
    assert offered(folder, "just run alpha/") == ["alpha/sub/"]


@pytest.mark.parametrize(
    ("line", "expected"),
    [
        # The last word is the word being typed.
        ("just ru", ["[just]", "[ru]"]),
        ("just run al", ["[just]", "[run]", "[al]"]),
        ("just project=al", ["[just]", "[project=al]"]),
        # It is an empty line when the cursor follows a space.
        ("just run ", ["[just]", "[run]", "[]"]),
        ("", ["[]"]),
        # Only the current command counts, not the one before the pipe.
        ("echo a | just ru", ["[just]", "[ru]"]),
    ],
)
def test_commandline_words(folder, line, expected):
    """commandline-words prints the words up to the cursor, one per line."""
    assert run(folder, line, PRINT_WORDS) == expected


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q", "-p", "no:cacheprovider"]))
