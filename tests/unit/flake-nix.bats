#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../flake.nix"
}

@test "ci devShell sets BATS_LIB_PATH env var" {
    run grep "BATS_LIB_PATH" "$CONFIG"
    assert_output --partial 'BATS_LIB_PATH = "'
}

@test "ci devShell BATS_LIB_PATH references batsWithLibs" {
    run grep "BATS_LIB_PATH" "$CONFIG"
    assert_output --partial 'batsWithLibs'
}

@test "ci devShell BATS_LIB_PATH ends with /share/bats" {
    run grep "BATS_LIB_PATH" "$CONFIG"
    assert_output --partial '/share/bats'
}

@test "default devShell substitutes BATS_LIB_PATH via replaceStrings" {
    run grep "replaceStrings" "$CONFIG"
    assert_output --partial '@BATS_LIB_PATH@'
}
