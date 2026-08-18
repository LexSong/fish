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

## Completions: auto-discovery is not worth fixing here

Completion harnesses solve **discovery**; shell history solves **repetition**.
This setup is repetition-shaped — the same handful of invocations, recalled
whole by fish's autosuggestion, *including the argument values*. A completion
file only ever offers the flag name.

So: **no generated or vendored completion files.** They are a standing
obligation — regenerate, re-apply fixes, keep stubs in sync — paid for a
tab-complete. Don't add one back for a tool that lacks completions (yt-dlp
generates its fish completion at build time and ships it in neither the repo
nor the PyPI wheel; that is fine, leave it).

`completions/just.fish` is the one entry, and shows the bar: it is hand-written
(so it never regenerates and never drifts), `just` is something we actually run,
and it emits genuinely dynamic values — recipe names from whichever justfile is
in scope, which history cannot cover. Clear all three or don't add it.

If something ever genuinely itches, hand-write a line or two for the flags
actually used.
