function llama --description 'Run the pi agent in an sbx sandbox using the llama kit'
    sbx run --kit /d/sbx-kits/llama llama -- $argv
end
