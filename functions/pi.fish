function pi --description 'Run the pi agent in an sbx sandbox using the pi kit'
    sbx run --kit /d/sbx-kits/pi pi -- $argv
end
