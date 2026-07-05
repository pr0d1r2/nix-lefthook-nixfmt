#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../../../.github/workflows/update-pins.yml"
}

@test "uses actions/checkout@v6" {
    run grep "actions/checkout@v6" "$CONFIG"
    assert_success
}

@test "does not use actions/checkout@v4" {
    run grep "actions/checkout@v4" "$CONFIG"
    assert_failure
}

@test "runs nix flake update" {
    run grep "nix flake update" "$CONFIG"
    assert_success
}

@test "runs nix flake check" {
    run grep "nix flake check" "$CONFIG"
    assert_success
}

@test "runs on schedule" {
    run grep "schedule:" "$CONFIG"
    assert_success
}

@test "supports workflow_dispatch" {
    run grep "workflow_dispatch" "$CONFIG"
    assert_success
}
