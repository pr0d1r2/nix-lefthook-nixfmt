#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    LOCK="$BATS_TEST_DIRNAME/../../flake.lock"
}

@test "nixpkgs lock uses the brotli-fixed nixos-26.05 revision" {
    run awk '
        /"nixpkgs(_[0-9]+)?": \{/ { in_node = 1; nodes++ }
        in_node && /"rev":/ {
            if ($0 !~ /"rev": "c56a87d8e41ce69bd2af57eb35dcc117a9dfca33"/) {
                bad = 1
            }
            in_node = 0
            revisions++
        }
        END { exit !(nodes > 0 && nodes == revisions && !bad) }
    ' "$LOCK"
    assert_success
}
