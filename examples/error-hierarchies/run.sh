#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

"${CXX:-clang++}" -std=c++23 -Wno-exceptions \
    "$example_dir/cpp/exceptions.cpp" -o "$build_dir/exceptions"
"${CXX:-clang++}" -std=c++23 -Wall -Wextra -Werror \
    "$example_dir/cpp/expected.cpp" -o "$build_dir/expected"
"${RUSTC:-rustc}" --edition=2021 -D warnings \
    "$example_dir/rust/result.rs" -o "$build_dir/result"
"${RUSTC:-rustc}" --edition=2021 -D warnings -C panic=unwind \
    "$example_dir/rust/panic.rs" -o "$build_dir/panic"

printf '%s\n' '=== C++ exceptions (cpp/exceptions.cpp) ==='
"$build_dir/exceptions"

printf '\n%s\n' '=== C++ std::expected (cpp/expected.cpp) ==='
"$build_dir/expected"

printf '\n%s\n' '=== Rust Result (rust/result.rs) ==='
"$build_dir/result"

printf '\n%s\n' '=== Rust panic (rust/panic.rs) ==='
RUST_BACKTRACE=0 "$build_dir/panic" 2>&1
