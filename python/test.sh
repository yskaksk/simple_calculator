#!/bin/bash
assert() {
    expected="$1"
    input="$2"

    python3 ./calculator.py "$input"
    actual=$(python3 ./calculator.py "$input")

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
assert 4 "2 * 2"
assert 7 "1 + 2 * 3"
assert 9 "(1 + 2) * 3"
assert 3 "(-1 + 2) * 3"
assert 1 "-1 * -1"
assert 1 "--1"
assert 1 "-+-1"
assert 3 "2 + -+-1"
assert 1024.0 "(3 - 1)^(1 + 3 * 3)"

echo OK
