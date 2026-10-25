# fish config repo notes

My interactive shell is MSYS2 fish. MSYS2 is a thin layer with fish, bash and
coreutils. The real tools (`rg`, `fd`, `uv`, `git`, `just`) come from scoop shims
on the Windows PATH, so they behave the same in fish and in Git Bash.

## Running fish

Run fish only to test or check fish config. The `fish` on PATH is a scoop shim
that starts the MSYS2 launcher without `-no-start`, so it detaches instead of
running inline. Use these instead:

- Login environment: `msys2 -no-start -defterm -shell fish -here -c '<fish code>'`.
  `-no-start` runs it inline and passes back the exit code. `-where DIR` sets
  the working directory.
- Syntax check: `/c/Users/LexSong/scoop/apps/msys2/current/usr/bin/fish.exe -n file.fish`.

## What belongs here

Every function here wraps a command. A function that arranges commands that
already exist (`update-all` wraps `topgrade`, `gpu-limit` wraps `nvidia-smi`)
stays here, however long it gets. A payload that had to be written doesn't
belong in shell config. It goes to `~/windows-setup/scripts/` or to its own uv
tool repo, and a function keeps at most the invocation.

Two cases are forced. A function that shadows the binary it calls (`restic`,
which uses `command` inside) can only be a function. Anything a non-fish caller
needs must be a script or a uv tool.

## Completions

Ask the tool for the values at completion time. `just` has its own completion
protocol, and git answers with `for-each-ref` and `ls-files`.

Do not store completion data: no generated or vendored files, and no copy of a
tool's flag list. A short static list is fine when the values almost never
change, such as subcommand names.

Sometimes a tool's own completion is broken, or fish's bundled one is too slow.
We fix those here when the cost is reasonable. That is a judgement call per
command, so ask.
