#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    export TMP="$BATS_TEST_TMPDIR"
    SCRIPT="$BATS_TEST_DIRNAME/../../../../scripts/lefthook/taplo-check.sh"

    mkdir -p "$TMP/bin"
    sed "s|@BASH@|$(command -v bash)|" > "$TMP/bin/timeout" <<'SH'
#!@BASH@
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    sed "s|@BASH@|$(command -v bash)|" > "$TMP/bin/taplo" <<'SH'
#!@BASH@
echo "taplo $*" >> "$TMP/taplo.log"
SH
    chmod +x "$TMP/bin/taplo"

    export PATH="$TMP/bin:$PATH"
}

@test "passes all arguments to taplo check via timeout" {
    run bash "$SCRIPT" .rtk/filters.toml
    assert_success
    run cat "$TMP/taplo.log"
    assert_output "taplo check .rtk/filters.toml"
}

@test "uses default timeout of 30 seconds" {
    sed "s|@BASH@|$(command -v bash)|" > "$TMP/bin/timeout" <<'SH'
#!@BASH@
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    unset LEFTHOOK_TAPLO_TIMEOUT
    run bash "$SCRIPT" .rtk/filters.toml
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=30"
}

@test "respects LEFTHOOK_TAPLO_TIMEOUT override" {
    sed "s|@BASH@|$(command -v bash)|" > "$TMP/bin/timeout" <<'SH'
#!@BASH@
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    LEFTHOOK_TAPLO_TIMEOUT=60 run bash "$SCRIPT" .rtk/filters.toml
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=60"
}

@test "propagates taplo exit code on failure" {
    sed "s|@BASH@|$(command -v bash)|" > "$TMP/bin/taplo" <<'SH'
#!@BASH@
exit 1
SH
    chmod +x "$TMP/bin/taplo"

    run bash "$SCRIPT" .rtk/filters.toml
    assert_failure
}

@test "passes shellcheck" {
    run shellcheck "$SCRIPT"
    assert_success
}
