#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
ulimit -c 0

run_sample() {
    printf '\n== %s ==\n' "$2"
    "$build_dir/$1" >"$build_dir/$1.out" 2>&1
    cat "$build_dir/$1.out"
}

run_expected_abort() {
    printf '\n== %s ==\n' "$2"
    abort_status=0

    # Run through a child shell so its SIGABRT diagnostic can be hidden while
    # the program's own teaching output remains available in the output file.
    sh -c '"$1" >"$2" 2>&1' sh \
        "$build_dir/$1" "$build_dir/$1.out" 2>/dev/null || abort_status=$?

    if test "$abort_status" -ne 134; then
        cat "$build_dir/$1.out"
        printf 'expected exit status 134, got %s\n' "$abort_status" >&2
        exit 1
    fi

    cat "$build_dir/$1.out"
    printf '%s\n' 'result: process aborted as expected; the harness continues'
}

for sample in vector-growth vector-growth-noexcept vector-growth-move-only move-traits; do
    "${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
        "$example_dir/cpp/$sample.cpp" -o "$build_dir/$sample"
done
run_sample vector-growth 'C++: throwing move available, so vector copies'
run_sample vector-growth-noexcept 'C++: noexcept move, so vector moves'
run_sample vector-growth-move-only 'C++: copy deleted, so vector must move'
run_sample move-traits 'C++: which move constructors are noexcept?'

grep -q '^  copy ' "$build_dir/vector-growth.out"
grep -q '^  move ' "$build_dir/vector-growth-noexcept.out"
grep -q '^  move ' "$build_dir/vector-growth-move-only.out"
if grep -Eq '^  move ' "$build_dir/vector-growth.out" ||
   grep -Eq '^  copy ' "$build_dir/vector-growth-noexcept.out" "$build_dir/vector-growth-move-only.out"; then
    exit 1
fi
diff -u - "$build_dir/move-traits.out" <<'TRAITS'
Written   false
Promised  true
Defaulted true
Implicit  true
Holder    false
TRAITS

# This source intentionally throws from a noexcept function, so its compiler
# warning is captured instead of mixed into the learner-facing runtime output.
if ! "${CXX:-c++}" -std=c++17 -Wall -Wextra \
    "$example_dir/cpp/noexcept-boundary.cpp" -o "$build_dir/noexcept-boundary" \
    2>"$build_dir/noexcept-boundary.compile"; then
    cat "$build_dir/noexcept-boundary.compile" >&2
    exit 1
fi
run_expected_abort noexcept-boundary 'C++: exception cannot cross noexcept boundary'
grep -Fq 'risky: about to throw' "$build_dir/noexcept-boundary.out"
if grep -Eq '^(caught:|main: still running)' "$build_dir/noexcept-boundary.out"; then
    exit 1
fi

for sample in vec_growth string_move try_reserve unwind_boundary; do
    rustc --edition=2021 -D warnings -C panic=unwind \
        "$example_dir/rust/$sample.rs" -o "$build_dir/$sample"
done
run_sample vec_growth 'Rust: Vec growth moves elements without Clone'
awk '
    /^end / { ended = 1 }
    /^  clone / || (/^  drop / && !ended) { unexpected = 1 }
    /^  drop / { drops++ }
    END { exit (unexpected || drops != 6) }
' "$build_dir/vec_growth.out"

run_sample string_move 'Rust: String move reuses the buffer; clone copies it'
set -- $(awk '{print $NF}' "$build_dir/string_move.out")
test "$#" -eq 3
test "$1" = "$2"
test "$2" != "$3"

run_sample try_reserve 'Rust: failed try_reserve preserves the Vec'
grep -q '^error: ' "$build_dir/try_reserve.out"
grep -Fq 'values are still [1, 2, 3]' "$build_dir/try_reserve.out"

run_expected_abort unwind_boundary 'Rust: ordinary panic caught; extern "C" panic cannot unwind'
grep -Fq 'ordinary caught: true' "$build_dir/unwind_boundary.out"
grep -Fq 'panic in a function that cannot unwind' "$build_dir/unwind_boundary.out"
if grep -q '^boundary caught:' "$build_dir/unwind_boundary.out"; then
    exit 1
fi

printf '\n%s\n' 'All noexcept and move observations matched the expected behavior.'
