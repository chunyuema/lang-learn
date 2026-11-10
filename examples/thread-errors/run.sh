#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
cxx=${CXX:-c++}

for source in exception-ptr multiple-workers uncaught; do
    "$cxx" -std=c++17 -Wall -Wextra -Werror -pthread \
        "$example_dir/cpp/$source.cpp" -o "$build_dir/$source"
done
for source in panic_join result_join channel_loss; do
    rustc --edition=2021 -D warnings "$example_dir/rust/$source.rs" -o "$build_dir/$source"
done

printf '%s\n' '== C++: catch, store, join, and rethrow =='
"$build_dir/exception-ptr"
printf '\n%s\n' '== C++: one exception slot per worker =='
"$build_dir/multiple-workers"
printf '\n%s\n' '== Rust: panic payload returned by join =='
"$build_dir/panic_join" 2>&1
printf '\n%s\n' '== Rust: Result inside the join Result =='
"$build_dir/result_join" 2>&1
printf '\n%s\n' '== Rust: a channel misses a panic; joining detects it =='
"$build_dir/channel_loss" 2>&1

printf '\n%s\n' '== C++: uncaught worker exception (expected process termination) =='
if "$build_dir/uncaught" >"$build_dir/uncaught.out" 2>&1; then
    printf '%s\n' 'Expected uncaught.cpp to terminate, but it exited successfully.' >&2
    exit 1
fi
cat "$build_dir/uncaught.out"
if grep -q 'main: caught' "$build_dir/uncaught.out"; then
    printf '%s\n' "main's catch unexpectedly handled the worker exception." >&2
    exit 1
fi
printf '%s\n' "Observed termination; main's catch did not run."

