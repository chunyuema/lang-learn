#!/bin/sh
set -eu

example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
. "$repo_dir/harness.sh"
harness_init

for sample in vector-growth vector-growth-noexcept vector-growth-move-only move-traits; do
    "${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
        "$example_dir/cpp/$sample.cpp" -o "$HARNESS_BUILD_DIR/$sample"
done
run_sample vector-growth 'C++: throwing move available, so vector copies' \
    "$HARNESS_BUILD_DIR/vector-growth"
run_sample vector-growth-noexcept 'C++: noexcept move, so vector moves' \
    "$HARNESS_BUILD_DIR/vector-growth-noexcept"
run_sample vector-growth-move-only 'C++: copy deleted, so vector must move' \
    "$HARNESS_BUILD_DIR/vector-growth-move-only"
run_sample move-traits 'C++: which move constructors are noexcept?' \
    "$HARNESS_BUILD_DIR/move-traits"

grep -q '^  copy ' "$(harness_output vector-growth)"
grep -q '^  move ' "$(harness_output vector-growth-noexcept)"
grep -q '^  move ' "$(harness_output vector-growth-move-only)"
if grep -Eq '^  move ' "$(harness_output vector-growth)" ||
   grep -Eq '^  copy ' "$(harness_output vector-growth-noexcept)" \
       "$(harness_output vector-growth-move-only)"; then
    exit 1
fi
diff -u - "$(harness_output move-traits)" <<'TRAITS'
Written   false
Promised  true
Defaulted true
Implicit  true
Holder    false
TRAITS

# This source intentionally throws from a noexcept function, so its compiler
# warning is captured instead of mixed into the learner-facing runtime output.
if ! "${CXX:-c++}" -std=c++17 -Wall -Wextra \
    "$example_dir/cpp/noexcept-boundary.cpp" -o "$HARNESS_BUILD_DIR/noexcept-boundary" \
    2>"$HARNESS_BUILD_DIR/noexcept-boundary.compile"; then
    cat "$HARNESS_BUILD_DIR/noexcept-boundary.compile" >&2
    exit 1
fi
run_expected_abort noexcept-boundary 'C++: exception cannot cross noexcept boundary' \
    "$HARNESS_BUILD_DIR/noexcept-boundary"
grep -Fq 'risky: about to throw' "$(harness_output noexcept-boundary)"
if grep -Eq '^(caught:|main: still running)' "$(harness_output noexcept-boundary)"; then
    exit 1
fi

for sample in vec_growth string_move try_reserve unwind_boundary; do
    rustc --edition=2021 -D warnings -C panic=unwind \
        "$example_dir/rust/$sample.rs" -o "$HARNESS_BUILD_DIR/$sample"
done
run_sample vec_growth 'Rust: Vec growth moves elements without Clone' \
    "$HARNESS_BUILD_DIR/vec_growth"
awk '
    /^end / { ended = 1 }
    /^  clone / || (/^  drop / && !ended) { unexpected = 1 }
    /^  drop / { drops++ }
    END { exit (unexpected || drops != 6) }
' "$(harness_output vec_growth)"

run_sample string_move 'Rust: String move reuses the buffer; clone copies it' \
    "$HARNESS_BUILD_DIR/string_move"
set -- $(awk '{print $NF}' "$(harness_output string_move)")
test "$#" -eq 3
test "$1" = "$2"
test "$2" != "$3"

run_sample try_reserve 'Rust: failed try_reserve preserves the Vec' \
    "$HARNESS_BUILD_DIR/try_reserve"
grep -q '^error: ' "$(harness_output try_reserve)"
grep -Fq 'values are still [1, 2, 3]' "$(harness_output try_reserve)"

run_expected_abort unwind_boundary 'Rust: ordinary panic caught; extern "C" panic cannot unwind' \
    "$HARNESS_BUILD_DIR/unwind_boundary"
grep -Fq 'ordinary caught: true' "$(harness_output unwind_boundary)"
grep -Fq 'panic in a function that cannot unwind' "$(harness_output unwind_boundary)"
if grep -q '^boundary caught:' "$(harness_output unwind_boundary)"; then
    exit 1
fi

harness_complete 'All noexcept and move observations matched the expected behavior.'
