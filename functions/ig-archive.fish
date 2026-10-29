function ig-archive --description 'Download Instagram posts into the current dump folder; args go to gallery-dl'
    # Expected dump folder, which is the current folder:
    #   instagram.txt          profile URLs, one per line (gallery-dl -i format)
    #   archive.sqlite3        IDs of downloaded posts, written by gallery-dl
    #   gallery-dl/instagram/  posts, one folder per user (collab posts land
    #                          under the other account's name)
    # Without instagram.txt, pass the URLs as args instead.
    set -l input
    if test -f instagram.txt
        set input -i instagram.txt
    end

    # gallery-dl is a Windows exe, so the cookies path uses USERPROFILE.
    gallery-dl --cookies "$USERPROFILE\.cookies\www.instagram.com_cookies.txt" \
        --download-archive archive.sqlite3 \
        --sleep-request 5-10 \
        $input $argv
end
