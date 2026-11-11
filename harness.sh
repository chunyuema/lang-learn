#!/bin/sh

# Shared presentation and process-control helpers for the topic runners.
# Topic scripts still own compilation and concept-specific assertions.

harness_init() {
    HARNESS_BUILD_DIR=$(mktemp -d)
    export HARNESS_BUILD_DIR
    trap 'rm -rf "$HARNESS_BUILD_DIR"' EXIT
    ulimit -c 0
}

harness_output() {
    printf '%s/%s.out\n' "$HARNESS_BUILD_DIR" "$1"
}

harness_heading() {
    printf '\n== %s ==\n' "$1"
}

run_sample() {
    harness_sample_id=$1
    harness_sample_title=$2
    shift 2

    HARNESS_LAST_OUTPUT=$(harness_output "$harness_sample_id")
    harness_heading "$harness_sample_title"

    harness_sample_status=0
    "$@" >"$HARNESS_LAST_OUTPUT" 2>&1 || harness_sample_status=$?
    if test "$harness_sample_status" -ne 0; then
        cat "$HARNESS_LAST_OUTPUT"
        printf 'sample exited with status %s\n' "$harness_sample_status" >&2
        exit 1
    fi

    cat "$HARNESS_LAST_OUTPUT"
}

run_expected_abort() {
    harness_sample_id=$1
    harness_sample_title=$2
    shift 2

    HARNESS_LAST_OUTPUT=$(harness_output "$harness_sample_id")
    harness_heading "$harness_sample_title"
    harness_sample_status=0

    # The child shell converts SIGABRT into status 134. Its own signal message
    # is hidden, while the sample's teaching output is retained and displayed.
    sh -c 'harness_output_file=$1; shift; "$@" >"$harness_output_file" 2>&1' \
        sh "$HARNESS_LAST_OUTPUT" "$@" 2>/dev/null || harness_sample_status=$?

    if test "$harness_sample_status" -ne 134; then
        cat "$HARNESS_LAST_OUTPUT"
        printf 'expected abort status 134, got %s\n' "$harness_sample_status" >&2
        exit 1
    fi

    cat "$HARNESS_LAST_OUTPUT"
    printf '%s\n' 'result: process aborted as expected; the harness continues'
}

harness_complete() {
    printf '\n%s\n' "$1"
}
