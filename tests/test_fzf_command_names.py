# /// script
# requires-python = ">=3.12"
# dependencies = ["pytest"]
# ///
"""Test that the command-name lister gives exactly fish's list, on this machine.

Run: uv run tests/test_fzf_command_names.py

The reference is `complete -C ''`. Every allowed difference is named below, so a
new difference fails the test.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent

# The lister keeps files with these extensions. fish also lists other files,
# because they start with the PE magic `MZ` or a shebang: `.dll`, `.sys`, `.ps1`.
KEPT_EXTENSIONS = {"", ".exe", ".com"}
# fish's PATH adds this folder to the Windows PATH.
MSYS2_BIN = Path.home() / "scoop/apps/msys2/current/usr/bin"

# System32 holds a folder with each of these names, next to NAME.exe. So fish
# lists NAME.exe, and we list NAME.
SAME_NAME_AS_FOLDER = {"Dism", "MRT", "msdtc"}
# The lister globs `*.exe` and `*.EXE`, so it misses SppExtComObj.Exe. Windows runs
# it as a background process, so nobody types it.
MIXED_CASE_EXE = {"SppExtComObj"}


def login_fish(code: str) -> list[str]:
    """Run code in the login fish, through a file: the msys2 shim is a cmd script."""
    with tempfile.TemporaryDirectory() as tmp:
        script = Path(tmp) / "run.fish"
        script.write_text(code, encoding="utf-8")
        path = "/" + script.as_posix().replace(":", "", 1)
        result = subprocess.run(
            f'msys2 -no-start -defterm -shell fish -here -c "source {path}"',
            cwd=REPO,
            shell=True,
            capture_output=True,
            encoding="utf-8",
            check=True,
        )
    return result.stdout.splitlines()


def files_the_lister_drops() -> set[str]:
    """Read real file names, because fish prints `mkfs.bfs.exe` as `mkfs.bfs`."""
    names = set()
    for folder in [*os.environ["PATH"].split(";"), MSYS2_BIN]:
        if os.path.isdir(folder):
            for entry in os.scandir(folder):
                if os.path.splitext(entry.name)[1].lower() not in KEPT_EXTENSIONS:
                    names.add(entry.name)
    return names


def test_lister_equals_fish():
    fish = set(login_fish("builtin complete -C '' | string replace -r '\\t.*' ''"))
    output = login_fish("fzf-command-names | string unescape")
    ours = set(output)
    dropped = files_the_lister_drops()

    assert ours - fish == SAME_NAME_AS_FOLDER
    assert (
        fish - ours - dropped
        == {f"{name}.exe" for name in SAME_NAME_AS_FOLDER} | MIXED_CASE_EXE
    )
    assert ours & dropped == set()
    assert len(output) == len(ours), "listed twice"


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q", "-p", "no:cacheprovider"]))
