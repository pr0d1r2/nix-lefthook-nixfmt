#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-nixfmt
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-nixfmt /nonexistent/file.nix
    assert_success
}

@test "non-nix files are skipped" {
    echo 'hello' > "$TMP/readme.md"
    run lefthook-nixfmt "$TMP/readme.md"
    assert_success
}

@test "well-formatted nix file passes" {
    cat > "$TMP/good.nix" <<'NIX'
{
  foo = "bar";
}
NIX
    run lefthook-nixfmt --check "$TMP/good.nix"
    assert_success
}

@test "badly-formatted nix file fails" {
    cat > "$TMP/bad.nix" <<'NIX'
{
foo="bar";
}
NIX
    run lefthook-nixfmt --check "$TMP/bad.nix"
    assert_failure
}

@test "multiple files: only bad one causes failure" {
    cat > "$TMP/good.nix" <<'NIX'
{
  foo = "bar";
}
NIX
    cat > "$TMP/bad.nix" <<'NIX'
{
foo="bar";
}
NIX
    run lefthook-nixfmt --check "$TMP/good.nix" "$TMP/bad.nix"
    assert_failure
}

@test "--format mode reformats in place" {
    cat > "$TMP/messy.nix" <<'NIX'
{
foo="bar";
}
NIX
    run lefthook-nixfmt --format "$TMP/messy.nix"
    assert_success
    run lefthook-nixfmt --check "$TMP/messy.nix"
    assert_success
}

@test "default mode is --check" {
    cat > "$TMP/bad.nix" <<'NIX'
{
foo="bar";
}
NIX
    run lefthook-nixfmt "$TMP/bad.nix"
    assert_failure
}
