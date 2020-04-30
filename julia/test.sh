#!/bin/bash
assert() {
    expected="$1"
    input="$2"

    actual=$(julia ./calculator.jl "$input")

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

assert 0 0
assert 123 123
assert 3 "1+2"
assert 6 "1 + 2 + 3"
assert 3 "11 + 22 - 30"

echo OK
