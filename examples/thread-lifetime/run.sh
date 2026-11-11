#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
. "$repo_dir/harness.sh"
harness_init

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror -pthread \
    "$example_dir/cpp/thread-and-crash.cpp" -o "$HARNESS_BUILD_DIR/thread-and-crash"

run_expected_abort thread-and-crash \
    'C++: destroying a joinable thread during unwinding terminates the process' \
    "$HARNESS_BUILD_DIR/thread-and-crash"
