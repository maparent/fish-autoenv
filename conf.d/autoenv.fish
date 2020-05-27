# get the intial PWD for the first time
# we can't get it from $dirprev from the first jump
set -g __autoenv_init_pwd $PWD

function __autoenv --on-variable PWD --on-variable fish_pid

    status --is-command-substitution; and return

    test -z $FISH_AUTOENV_AUTH_FILE; \
        and set -g FISH_AUTOENV_AUTH_FILE "$HOME/.fish-autoenv.authorized"

    test "x$__autoenv_old_path" = "x"; \
        and set -g __autoenv_old_path $__autoenv_init_pwd

    # we didn't enter a new directory
    test "x$__autoenv_old_path" = "x$PWD"; and return

    # Let's do OUT first from the previous path
    # and record the paths
    set -l commonpath ""
    if test "x$__autoenv_old_path" != "x"
        while true
            # if I am part of new path (PWD), meaning I am a parent
            # So we shall not do OUT
            if string match -q "x$__autoenv_old_path/*" "x$PWD"
                set commonpath $__autoenv_old_path
                break
            end
            test -f $__autoenv_old_path/.out.fish; \
                and source $__autoenv_old_path/.out.fish
            set __autoenv_old_path (dirname $__autoenv_old_path)
            # use "" instead of "/", since we will connenct the path Later
            # by $oldpath/...
            test "x$__autoenv_old_path" = "x/"; \
                and set __autoenv_old_path ""
        end
    end

    # Let's iterate from $commonpath to $PWD and see if there are .in.fish files
    # along the paths
    set -l newpath $PWD
    set -l infiles ""

    while true
        test "x$newpath" = "x$commonpath"; and break
        test -f $newpath/.in.fish; and set infiles $newpath/.in.fish $infiles
        set newpath (dirname $newpath)
        test "x$newpath" = "x/"; and set newpath ""
    end

    for infile in $infiles
        __autoenv_exec $infile
    end

    set __autoenv_old_path $PWD
end
