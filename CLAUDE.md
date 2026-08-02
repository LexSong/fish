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

## Fixing regenerated `completions/sbx.exe.fish`

`sbx` (Cobra-based) can regenerate its own fish completion file (e.g. via
`sbx completion fish > completions/sbx.exe.fish`). The raw output is broken
in fish (raw generator output is not kept in git — apply the fix directly to
the regenerated file before committing).

**Dotted global variable names are invalid in fish.** Fish variable names may
only contain alnum + `_`; a `.` silently ends the variable name during
`$var.exe...` expansion, so the two generated global vars
(`__sbx.exe_perform_completion_once_result` and `__sbx.exe_comp_results`)
never actually get set/read — completion fails silently. Fix by replacing
`.` with `_` in *only these two variable names* (not the function names —
dots are fine there, e.g. `__sbx.exe_debug` stays as-is):

```
sed -i \
  -e 's/__sbx\.exe_perform_completion_once_result/__sbx_exe_perform_completion_once_result/g' \
  -e 's/__sbx\.exe_comp_results/__sbx_exe_comp_results/g' \
  completions/sbx.exe.fish
```

## `completions/sbx.fish` (bare `sbx` command name)

The generator only registers the literal command name it's given (`sbx.exe`),
so plain `sbx` (no `.exe`) would get no completions. `completions/sbx.fish` is
a hand-maintained stub that sources `sbx.exe.fish` (to load its helper
functions) and then re-runs the final `complete -c ...` block against `sbx`.

It is **not** regenerated — leave it alone when regenerating `sbx.exe.fish`.
The one coupling: its `complete ... -a '$__sbx_exe_comp_results'` lines
reference the underscored variable name from the fix above, so keep them in
sync if that name ever changes.

After fixing, sanity-check with `fish -n completions/sbx.exe.fish` and by
tab-completing both `sbx.exe <TAB>` and `sbx <TAB>` in a fresh fish session.
