#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
. "$repo_dir/harness.sh"
harness_init

run_sample self-address 'Rust: addresses while borrowing and moving self' \
    "${CARGO:-cargo}" run --quiet \
        --manifest-path "$example_dir/rust/self-address/Cargo.toml"
