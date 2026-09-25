#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../flake.nix"
}

@test "outputs delegate to set-and-setting mkConsumerFlake" {
    run grep "mkConsumerFlake" "$CONFIG"
    assert_output --partial 'set-and-setting.lib.mkConsumerFlake {'
}

@test "outputs body has no top-level let block" {
    run grep -E '^    let$' "$CONFIG"
    assert_failure
}

@test "packages default uses writeShellApplication" {
    run grep "writeShellApplication" "$CONFIG"
    assert_output --partial 'writeShellApplication'
}

@test "unit check reads script via builtins.readFile" {
    run grep "readFile ./scripts/unit-tests.sh" "$CONFIG"
    assert_success
}

@test "set-and-setting follows the top-level nixpkgs pins" {
    run grep -E '^      inputs\.nixpkgs\.follows = "nixpkgs";$' "$CONFIG"
    assert_success
    run grep -E '^      inputs\.nixpkgs-lock\.follows = "nixpkgs-lock";$' "$CONFIG"
    assert_success
}

@test "no separate set-and-setting-lib input" {
    run grep "set-and-setting-lib" "$CONFIG"
    assert_failure
}

@test "devShells add raw shellcheck for the unit suite" {
    run grep "legacyPackages.\${system}.shellcheck" "$CONFIG"
    assert_success
}
