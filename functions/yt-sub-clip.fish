function yt-sub-clip --description 'Copy YouTube subtitles as plain text to the clipboard (extra args pass through to yt-sub-txt)'
    # Capture first, then copy. A redirect straight to /dev/clipboard would
    # replace the clipboard with nothing when yt-sub-txt fails.
    set -l text (yt-sub-txt $argv -o - | string collect)
    or return
    printf '%s\n' $text >/dev/clipboard
    and echo 'Transcript copied.'
end
