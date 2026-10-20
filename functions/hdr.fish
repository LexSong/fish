function hdr --description 'Run HDRCmd; after `on` or `off`, show the new status'
    HDRCmd $argv
    or return
    if contains -- "$argv[1]" on off
        HDRCmd status
    end
end
