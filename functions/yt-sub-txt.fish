function yt-sub-txt --description 'Download YouTube subtitles as plain text (extra args pass through to yt-dlp)'
    # The script lives in windows-setup (unlinked payload); this is its interface.
    # PEP 723 metadata in the file resolves its own deps, so no venv to manage.
    uv run --script ~/windows-setup/scripts/yt-sub-txt.py $argv
end
