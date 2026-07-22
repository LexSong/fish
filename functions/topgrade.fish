function topgrade --description 'Update topgrade via scoop, then run it (no self-update, skip powershell/system/store)'
    scoop update topgrade
    command topgrade --no-self-update --disable system microsoft_store powershell $argv
end
