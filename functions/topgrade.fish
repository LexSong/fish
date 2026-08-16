function topgrade --description 'Update everything: topgrade, plus what it cannot update itself (pwsh, MSYS2, neovim)'
    # scoop runs under pwsh, which is itself a scoop app, so it can't update pwsh.
    powershell.exe -noprofile -ex unrestricted -command 'scoop.ps1 update pwsh'
    scoop update topgrade
    command topgrade --no-self-update --disable system microsoft_store powershell vim $argv

    # topgrade has no MSYS2 step (its `dkp_pacman` is devkitPro's, not ours), and
    # topgrade.exe is a scoop Windows binary that never sees MSYS2's pacman — so
    # the shell we are running in is the one thing topgrade cannot update.
    echo -e '\n―― MSYS2 ――'
    # A pass that only upgrades the core (runtime, pacman) stops there and asks
    # you to restart MSYS2; re-run `topgrade` after doing so to get the rest.
    pacman -Syu

    # The `vim` step is disabled above and handled here instead: vim.pack is
    # driven directly, then blink.cmp's Rust fuzzy matcher is rebuilt against
    # the freshly updated sources (a no-op if they didn't change).
    echo -e '\n―― Neovim ――'
    # (`nvim --headless` exits 0 even when the -c lua throws, so chaining these
    # on $status would buy nothing — read the output for failures.)
    nvim --headless -c 'lua vim.pack.update(nil, { force = true })' -c quitall

    # The build prints nothing at all, even on a real cargo compile, so
    # announce it — otherwise it just looks like a hang.
    echo -e '\nRebuilding blink.cmp fuzzy matcher...'
    nvim --headless -c 'lua require("blink.cmp").build():pwait()' -c quitall
end
