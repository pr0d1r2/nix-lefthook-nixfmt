#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    LOCK="$BATS_TEST_DIRNAME/../../flake.lock"
}

@test "nixpkgs lock uses the brotli-fixed nixos-26.05 revision" {
    run grep -A8 '"nixpkgs": {' "$LOCK"
    assert_output --partial '"rev": "c56a87d8e41ce69bd2af57eb35dcc117a9dfca33"'
}
