#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMPDIR="$(mktemp -d)"
    export WATCH_LOG="$TMPDIR/watch_log"
    export USE_LOG="$TMPDIR/use_log"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "watches flake.nix" {
    run bash -c 'watch_file() { echo "$1" >> "$WATCH_LOG"; }; use() { :; }; source .envrc'
    assert_success
    run grep -x "flake.nix" "$WATCH_LOG"
    assert_success
}

@test "watches flake.lock" {
    run bash -c 'watch_file() { echo "$1" >> "$WATCH_LOG"; }; use() { :; }; source .envrc'
    assert_success
    run grep -x "flake.lock" "$WATCH_LOG"
    assert_success
}

@test "watches dev.sh" {
    run bash -c 'watch_file() { echo "$1" >> "$WATCH_LOG"; }; use() { :; }; source .envrc'
    assert_success
    run grep -x "dev.sh" "$WATCH_LOG"
    assert_success
}

@test "watches lefthook-nixfmt.sh" {
    run bash -c 'watch_file() { echo "$1" >> "$WATCH_LOG"; }; use() { :; }; source .envrc'
    assert_success
    run grep -x "lefthook-nixfmt.sh" "$WATCH_LOG"
    assert_success
}

@test "uses flake" {
    run bash -c 'watch_file() { :; }; use() { echo "$*" >> "$USE_LOG"; }; source .envrc'
    assert_success
    run grep -x "flake" "$USE_LOG"
    assert_success
}
