#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
. "$repo_dir/harness.sh"
harness_init
cxx=${CXX:-c++}

for source in exception-ptr multiple-workers uncaught; do
    "$cxx" -std=c++17 -Wall -Wextra -Werror -pthread \
        "$example_dir/cpp/$source.cpp" -o "$HARNESS_BUILD_DIR/$source"
done
for source in panic_join result_join channel_loss; do
    rustc --edition=2021 -D warnings \
        "$example_dir/rust/$source.rs" -o "$HARNESS_BUILD_DIR/$source"
done

run_sample exception-ptr 'C++: catch, store, join, and rethrow' \
    "$HARNESS_BUILD_DIR/exception-ptr"
run_sample multiple-workers 'C++: one exception slot per worker' \
    "$HARNESS_BUILD_DIR/multiple-workers"
run_sample panic_join 'Rust: panic payload returned by join' \
    "$HARNESS_BUILD_DIR/panic_join"
run_sample result_join 'Rust: Result inside the join Result' \
    "$HARNESS_BUILD_DIR/result_join"
run_sample channel_loss 'Rust: a channel misses a panic; joining detects it' \
    "$HARNESS_BUILD_DIR/channel_loss"

run_expected_abort uncaught 'C++: uncaught worker exception terminates the process' \
    "$HARNESS_BUILD_DIR/uncaught"
if grep -q 'main: caught' "$(harness_output uncaught)"; then
    printf '%s\n' "main's catch unexpectedly handled the worker exception." >&2
    exit 1
fi
