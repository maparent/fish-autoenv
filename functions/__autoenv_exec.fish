
function __autoenv_exec

    test ! -f $argv; and return

    test -z $FISH_AUTOENV_AUTH_FILE; \
        and set -g FISH_AUTOENV_AUTH_FILE "$HOME/.fish-autoenv.authorized"

    set shasum_bin
    which shasum >/dev/null ^/dev/null; \
        and set shasum_bin shasum; \
        or set shasum_bin sha1sum

    set hash (command $shasum_bin $argv | cut -d' ' -f1)

    if grep "$argv:$hash" "$FISH_AUTOENV_AUTH_FILE" >/dev/null ^/dev/null
        source $argv
    else
        echo "WARNING: This is the first time you are to source:"
        echo -n "         $argv"

        while true
            read -l -P "Allow? [y/N] " ans
            switch $ans
                case Y y
                    echo "$argv:$hash" >> $FISH_AUTOENV_AUTH_FILE
                    source $argv
                    break
                case '' N n
                    break
            end
        end
    end
end
