#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
    SCRIPT="$BATS_TEST_DIRNAME/../../../../scripts/lefthook/nixfmt-check.sh"

    mkdir -p "$TMP/bin"
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    cat > "$TMP/bin/nixfmt" <<'SH'
#!/usr/bin/env bash
echo "nixfmt $*" >> "$TMP/nixfmt.log"
SH
    chmod +x "$TMP/bin/nixfmt"

    export PATH="$TMP/bin:$PATH"
}

@test "passes all arguments to nixfmt --check via timeout" {
    run bash "$SCRIPT" a.nix b.nix
    assert_success
    run cat "$TMP/nixfmt.log"
    assert_output "nixfmt --check a.nix b.nix"
}

@test "uses default timeout of 30 seconds" {
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    unset LEFTHOOK_NIXFMT_TIMEOUT
    run bash "$SCRIPT" a.nix
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=30"
}

@test "respects LEFTHOOK_NIXFMT_TIMEOUT override" {
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    LEFTHOOK_NIXFMT_TIMEOUT=60 run bash "$SCRIPT" a.nix
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=60"
}

@test "propagates nixfmt exit code on failure" {
    cat > "$TMP/bin/nixfmt" <<'SH'
#!/usr/bin/env bash
exit 1
SH
    chmod +x "$TMP/bin/nixfmt"

    run bash "$SCRIPT" a.nix
    assert_failure
}

@test "passes shellcheck" {
    run shellcheck "$SCRIPT"
    assert_success
}
