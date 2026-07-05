#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    export TMP="$BATS_TEST_TMPDIR"
    SCRIPT="$BATS_TEST_DIRNAME/../../../../scripts/lefthook/markdownlint-check.sh"

    mkdir -p "$TMP/bin"
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    cat > "$TMP/bin/markdownlint" <<'SH'
#!/usr/bin/env bash
echo "markdownlint $*" >> "$TMP/markdownlint.log"
SH
    chmod +x "$TMP/bin/markdownlint"

    export PATH="$TMP/bin:$PATH"
}

@test "passes all arguments to markdownlint via timeout" {
    run bash "$SCRIPT" README.md SPEC.md
    assert_success
    run cat "$TMP/markdownlint.log"
    assert_output "markdownlint README.md SPEC.md"
}

@test "uses default timeout of 30 seconds" {
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    unset LEFTHOOK_MARKDOWNLINT_TIMEOUT
    run bash "$SCRIPT" README.md
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=30"
}

@test "respects LEFTHOOK_MARKDOWNLINT_TIMEOUT override" {
    cat > "$TMP/bin/timeout" <<'SH'
#!/usr/bin/env bash
echo "timeout=$1" >> "$TMP/timeout.log"
shift 1
exec "$@"
SH
    chmod +x "$TMP/bin/timeout"

    LEFTHOOK_MARKDOWNLINT_TIMEOUT=60 run bash "$SCRIPT" README.md
    assert_success
    run cat "$TMP/timeout.log"
    assert_output "timeout=60"
}

@test "propagates markdownlint exit code on failure" {
    cat > "$TMP/bin/markdownlint" <<'SH'
#!/usr/bin/env bash
exit 1
SH
    chmod +x "$TMP/bin/markdownlint"

    run bash "$SCRIPT" README.md
    assert_failure
}

@test "passes shellcheck" {
    run shellcheck "$SCRIPT"
    assert_success
}
