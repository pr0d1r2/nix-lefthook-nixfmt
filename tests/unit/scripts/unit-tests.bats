#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    SCRIPT="$BATS_TEST_DIRNAME/../../../scripts/unit-tests.sh"
}

@test "runs the complete unit suite recursively" {
    run grep 'bats --recursive tests/unit' "$SCRIPT"
    assert_success
}

@test "passes shellcheck" {
    run shellcheck "$SCRIPT"
    assert_success
}
