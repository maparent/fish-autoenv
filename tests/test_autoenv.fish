# --on-variable PWD not executing in @test of fishtape
# so we need to use native code for testing

set -g FISH_AUTOENV_AUTH_FILE /tmp/test_autoenv_auth

function test_it
    set -l func $argv[1]
    set -e argv[1]

    set -l msg (functions -v -D $func | tail -n1)

    $func $argv
    if test $status -eq 0
        echo "PASSED: $msg"
    else
        echo "FAILED: $msg"
    end
end

function test_normal_in --description "Normal in"
    set -l testdir /tmp/test_autoenv_normal_in_(date +"%F_%H_%M_%S").dir
    mkdir -p $testdir
    echo "echo 123 > $testdir/test" > $testdir/.in.fish

    __autoenv_exec $testdir/.in.fish < (echo y | psub) >/dev/null
    # remove it to eliminate the effect of __autoenv_exec
    rm -f $testdir/test

    pushd $testdir
    grep -w 123 $testdir/test >/dev/null ^/dev/null
    set out $status
    popd

    test $out -eq 0
end

function test_multi_in --description "Multiple in"
    set -l testdir /tmp/test_autoenv_multiple_in_(date +"%F_%H_%M_%S").dir
    mkdir -p $testdir/test1/test2
    echo "echo -n 1 >> $testdir/test" > $testdir/.in.fish
    echo "echo -n 2 >> $testdir/test" > $testdir/test1/.in.fish
    echo "echo -n 3 >> $testdir/test" > $testdir/test1/test2/.in.fish

    __autoenv_exec $testdir/.in.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/.in.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/test2/.in.fish < (echo y | psub) >/dev/null
    # remove it to eliminate the effect of __autoenv_exec
    rm -f $testdir/test

    pushd $testdir/test1/test2
    set out (cat $testdir/test)
    popd

    test $out = "123"
end

function test_single_out --description "Single out"
    set -l testdir /tmp/test_autoenv_single_out_(date +"%F_%H_%M_%S").dir
    mkdir -p $testdir
    echo "echo 123 > $testdir/test" > $testdir/.out.fish

    __autoenv_exec $testdir/.out.fish < (echo y | psub) >/dev/null
    # remove it to eliminate the effect of __autoenv_exec
    rm -f $testdir/test

    pushd $testdir
    popd

    test -f $testdir/test
    test $status -eq 0
end

function test_multi_out --description "Multiple out"
    set -l testdir /tmp/test_autoenv_(date +"%F_%H_%M_%S").dir
    mkdir -p $testdir/test1/test2
    echo "echo -n 1 >> $testdir/test" > $testdir/.out.fish
    echo "echo -n 2 >> $testdir/test" > $testdir/test1/.out.fish
    echo "echo -n 3 >> $testdir/test" > $testdir/test1/test2/.out.fish

    __autoenv_exec $testdir/.out.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/.out.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/test2/.out.fish < (echo y | psub) >/dev/null
    # remove it to eliminate the effect of __autoenv_exec
    rm -f $testdir/test

    pushd $testdir/test1/test2
    popd

    test (cat $testdir/test) = "321"
end

function test_multi_in_and_out --description "Multiple in and out"
    set -l testdir /tmp/test_autoenv_(date +"%F_%H_%M_%S").dir
    mkdir -p $testdir/test1/test2
    echo "echo -n i1 >> $testdir/test" > $testdir/.in.fish
    echo "echo -n i2 >> $testdir/test" > $testdir/test1/.in.fish
    echo "echo -n i3 >> $testdir/test" > $testdir/test1/test2/.in.fish
    echo "echo -n o1 >> $testdir/test" > $testdir/.out.fish
    echo "echo -n o2 >> $testdir/test" > $testdir/test1/.out.fish
    echo "echo -n o3 >> $testdir/test" > $testdir/test1/test2/.out.fish

    __autoenv_exec $testdir/.in.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/.in.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/test2/.in.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/.out.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/.out.fish < (echo y | psub) >/dev/null
    __autoenv_exec $testdir/test1/test2/.out.fish < (echo y | psub) >/dev/null
    # remove it to eliminate the effect of __autoenv_exec
    rm -f $testdir/test

    pushd $testdir/test1/test2
    popd

    test (cat $testdir/test) = "i1i2i3o3o2o1"
end

if test (count $argv) -eq 0
    test_it test_normal_in
    test_it test_multi_in
    test_it test_single_out
    test_it test_multi_out
    test_it test_multi_in_and_out
else
    test_it $argv
end

