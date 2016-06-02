#!/bin/bash

function run_test {
    for i in `seq 1 4`;
    do
        sed -i "s/[0-9]/$i/" $2;
        for j in `seq 0 2`;
        do
            racket $1 | grep "cpu time" &
        done;
        wait;
        echo "";
    done;
}

TEST_DIR=tests
ARGS_FILE=args.rkt

TESTS="simpleRA.rkt push-projection.rkt subquery-test.rkt subquery-exists.rkt magic-set.rkt aggr-pull-up.rkt aggr-join.rkt"

for test in $TESTS;
do
    echo "============== $test ==============";
    run_test $TEST_DIR/$test $TEST_DIR/$ARGS_FILE;
done;
wait
