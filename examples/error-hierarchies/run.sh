#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
. "$repo_dir/harness.sh"
harness_init

"${CXX:-clang++}" -std=c++23 -Wno-exceptions \
    "$example_dir/cpp/exceptions.cpp" -o "$HARNESS_BUILD_DIR/exceptions"
"${CXX:-clang++}" -std=c++23 -Wall -Wextra -Werror \
    "$example_dir/cpp/expected.cpp" -o "$HARNESS_BUILD_DIR/expected"
"${RUSTC:-rustc}" --edition=2021 -D warnings \
    "$example_dir/rust/result.rs" -o "$HARNESS_BUILD_DIR/result"
"${RUSTC:-rustc}" --edition=2021 -D warnings -C panic=unwind \
    "$example_dir/rust/panic.rs" -o "$HARNESS_BUILD_DIR/panic"

run_sample exceptions 'C++: exceptions' "$HARNESS_BUILD_DIR/exceptions"
run_sample expected 'C++: std::expected' "$HARNESS_BUILD_DIR/expected"
run_sample result 'Rust: Result' "$HARNESS_BUILD_DIR/result"
run_sample panic 'Rust: caught panic payload' \
    env RUST_BACKTRACE=0 "$HARNESS_BUILD_DIR/panic"
