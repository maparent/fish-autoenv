function setup
    set -g FISH_AUTOENV_AUTH_FILE /tmp/test_autoenv_auth
end

@test "exec: file not exists" -z (
    __autoenv_exec "__NonExistingFile__"
) # nothing output

@test "exec: file exists but not auth'ed" (
    rm -f $FISH_AUTOENV_AUTH_FILE
    set -l testfile /tmp/test_autoenv_(date +"%F_%H_%M_%S").fish
    echo "echo Something" > $testfile
    set -l out (__autoenv_exec $testfile < (echo y | psub))
    set out (string join "" $out)
    string match -q "[INFO   ] *[WARNING] *Something" $out
) $status -eq 0

@test "exec: auth'ed file" (
    rm -f $FISH_AUTOENV_AUTH_FILE
    set -l testfile /tmp/test_autoenv_(date +"%F_%H_%M").fish
    echo "echo Something" > $testfile
    __autoenv_exec $testfile < (echo y | psub) >/dev/null
    # auth'ed
    set -l out (__autoenv_exec $testfile)
    contains "Something" $out; \
        and ! contains "WARNING: This is the first time you are to source:" $out
) $status -eq 0

