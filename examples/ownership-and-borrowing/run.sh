#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

"${CARGO:-cargo}" run --quiet \
    --manifest-path "$example_dir/rust/self-address/Cargo.toml"
