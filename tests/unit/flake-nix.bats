#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../flake.nix"
}

@test "devShells uses set-and-setting mkDevShells" {
    run grep "mkDevShells" "$CONFIG"
    assert_output --partial 'set-and-setting.lib.mkDevShells'
}

@test "confirm app uses runtimeEnv for env vars" {
    run grep "runtimeEnv" "$CONFIG"
    assert_success
}

@test "confirm app reads script via builtins.readFile" {
    run grep "readFile ./scripts/confirm-app.sh" "$CONFIG"
    assert_success
}

@test "packages default uses writeShellApplication" {
    run grep "writeShellApplication" "$CONFIG"
    assert_output --partial 'writeShellApplication'
}
