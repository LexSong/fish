# fish config repo notes

## Environment / running fish

The user's **interactive** shell is MSYS2 Fish (root `scoop/apps/msys2/current`,
`MSYSTEM=MSYS`) — a deliberately *thin* layer holding fish + bash + coreutils and
essentially nothing else. All real tooling (`rg`, `fd`, `uv`, `git`, `just`, …)
comes from scoop shims on the shared Windows PATH and works from either side, so
the two MINGW roots almost never matter in practice.

**`fish` is not on my PATH**, and heavy work should not go through it anyway.
Invoke it only to run or validate fish config:

- Full login env: `msys2 -no-start -defterm -shell fish -here -c '<fish code>'`
  (`-where DIR` to set cwd; `-no-start` is what runs it inline and propagates the
  exit code — without it the launcher detaches).
- Quick syntax check, no login env needed:
  `/c/Users/LexSong/scoop/apps/msys2/current/usr/bin/fish.exe -n file.fish`.

## What belongs here, and what goes to windows-setup

Every function here wraps a command, and what it wraps decides where the work
lives. `topgrade` and `gpu-limit` wrap `topgrade` and `nvidia-smi` —
arrangements of commands that already exist, so they stay here however long they
get. `yt-sub-txt`, `pyproject`, and `checkup` wrap a payload that had to be
written; payloads don't belong in shell config, so those sit in
`~/windows-setup/scripts/` and the function keeps only the invocation.

Two cases are forced. A function that shadows the binary it calls (`restic`,
`topgrade`, both using `command` inside) can only ever be a function. Anything a
non-fish caller needs can only be a script — Claude's `SessionStart` hook runs
`sh`, which is why `project-checkup.sh` lives over there.

## Completions

Ask the tool for the values at completion time. `just` has its own completion
protocol. git answers with `for-each-ref` and `ls-files`. Nothing is stored here,
so nothing goes stale.

Do not store completion data. No generated or vendored files, and no copy of a
tool's flag list. A short static list is fine when the values almost never change,
such as subcommand names.

A tool's own mechanism is sometimes broken, and fish's bundled completion is
sometimes too slow. We fix those here when the cost is reasonable. That is a
judgement call per command. Ask.
