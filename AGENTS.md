# fish config repo notes

My interactive shell is MSYS2 fish. MSYS2 is an emulation layer that provides
fish, bash and coreutils. The real tools (`rg`, `fd`, `uv`, `git`, `just`) come
from scoop shims on the Windows PATH, so they behave the same in fish and in
Git Bash.

## Running fish

Fish is for my interactive use only. Do your work in Git Bash, PowerShell or
cmd, and start fish only to test this config.

The `fish` on PATH is a scoop shim. It starts the MSYS2 launcher without
`-no-start`, so it detaches instead of running inline. Use these instead:

- Login environment: `msys2 -no-start -defterm -shell fish -here -c '<fish code>'`.
  `-no-start` runs it inline and passes back the exit code. `-where DIR` sets
  the working directory.
- Syntax check: `/c/Users/LexSong/scoop/apps/msys2/current/usr/bin/fish.exe -n file.fish`.

## What belongs here

I read Python more easily than fish. Fish under MSYS2 also has performance
quirks that we chase from time to time. So the fish code here stays as lean as
possible. Write it only to solve a specific issue, never in advance.

The same goes for speed: measure, don't guess. Time the code before and after
a change, and report the numbers. Fish's `time` over-reports ~2.7x here, so
time the whole `fish.exe -c` process from bash.

Code that must run inside fish lives here: the prompt, event handlers, key
bindings, completions, and functions that shadow a command (`restic`,
`complete`). A function that runs commands I would otherwise type in fish also
stays here (`update-all` runs the update commands in a row).

Other logic goes to its own uv tool repo, and a function here keeps at most
the invocation. A non-fish caller cannot call a fish function, so anything it
needs goes to a uv tool too.

## Completions

A custom completion must earn its cost. That means a command I run often,
whose values history cannot recall: `just` recipe names, `git` branches. Other
commands rely on fish's general completion and history autosuggestion.

Ask the tool for the values at completion time, as `just` does with its own
completion protocol. Do not store completion data: no generated or vendored
files, and no copy of a tool's flag list. A short static list is fine when the
values almost never change, such as subcommand names.

A slow completion is better than a broken one. We fix a completion here when
it is broken, or when I find it slow enough to be worth fixing. I judge that by
feel, case by case, so ask first.
