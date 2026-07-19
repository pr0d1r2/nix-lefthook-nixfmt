#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    SCRIPT="$BATS_TEST_DIRNAME/../../../scripts/confirm-app.sh"
}

@test "confirm-app.sh exists" {
    [ -f "$SCRIPT" ]
}

@test "confirm-app.sh has shellcheck directive" {
    run head -1 "$SCRIPT"
    assert_output --partial '# shellcheck shell=bash'
}

@test "confirm-app.sh calls CONFIRM_SCRIPT" {
    run grep 'CONFIRM_SCRIPT' "$SCRIPT"
    assert_output --partial 'bash "$CONFIRM_SCRIPT"'
}

@test "confirm-app.sh passes shellcheck" {
    run shellcheck "$SCRIPT"
    assert_success
}
