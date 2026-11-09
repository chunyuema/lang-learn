#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror -pthread \
    "$example_dir/cpp/thread-and-crash.cpp" -o "$build_dir/thread-and-crash"

printf '%s\n' 'This example is expected to terminate because a joinable std::thread is destroyed during stack unwinding.'
if "$build_dir/thread-and-crash"; then
    printf '%s\n' 'Expected the program to terminate, but it exited successfully.' >&2
    exit 1
fi

printf '%s\n' 'Observed the expected abnormal termination.'
