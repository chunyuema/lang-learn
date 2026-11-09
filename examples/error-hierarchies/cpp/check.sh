#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cpp_dir="$example_dir/cpp"
rust_dir="$example_dir/rust"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
export LC_ALL=C

"${CXX:-clang++}" -std=c++23 -Wall -Wextra -Wexceptions \
    "$cpp_dir/exceptions.cpp" -o "$build_dir/exceptions" 2>"$build_dir/exceptions.log"
grep -q 'will be caught by earlier handler' "$build_dir/exceptions.log"
"$build_dir/exceptions" >"$build_dir/exceptions.actual"
diff -u - "$build_dir/exceptions.actual" <<'EOF'
base first: TimeoutError reached AppError handler
leaf first: TimeoutError handler
by reference: TimeoutError, server took too long
by value: AppError, server took too long
throw;
  middle saw: TimeoutError
  top: retry (TimeoutError)
throw e;
  middle saw: TimeoutError
  top: give up (AppError)
EOF

"${CXX:-clang++}" -std=c++23 -Wall -Wextra -Werror \
    "$cpp_dir/expected.cpp" -o "$build_dir/expected"
"${RUSTC:-rustc}" --edition=2021 -D warnings "$rust_dir/result.rs" -o "$build_dir/result"
"$build_dir/expected" >"$build_dir/expected.actual"
"$build_dir/result" >"$build_dir/result.actual"
diff -u - "$build_dir/expected.actual" <<'EOF'
got response
retry after 1500 ms
give up: connection refused
give up: missing app.toml
EOF
diff -u "$build_dir/expected.actual" "$build_dir/result.actual"

if "${RUSTC:-rustc}" --edition=2021 --cfg missing_from "$rust_dir/result.rs" \
    -o "$build_dir/missing_from" 2>"$build_dir/missing_from.log"; then
    printf '%s\n' 'Expected compilation to fail without From<NetworkError>.' >&2
    exit 1
fi
grep -q 'error\[E0277\]' "$build_dir/missing_from.log"
grep -q 'From<NetworkError>' "$build_dir/missing_from.log"

"${RUSTC:-rustc}" --edition=2021 -D warnings -C panic=unwind \
    "$rust_dir/panic.rs" -o "$build_dir/panic"
RUST_BACKTRACE=0 "$build_dir/panic" >"$build_dir/panic.actual" 2>"$build_dir/panic.log"
grep -q 'timeout after 1500 ms' "$build_dir/panic.log"
diff -u - "$build_dir/panic.actual" <<'EOF'
caught: Some("timeout after 1500 ms")
still running
EOF

printf '%s\n' 'All error-hierarchy checks passed.'
