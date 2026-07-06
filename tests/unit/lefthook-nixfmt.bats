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
    if [ "$status" -ne 0 ] && [[ "$output" == *"setOwnerAndGroup"* ]]; then
        skip "nixfmt atomic writes not supported in this environment"
    fi
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

@test "mixed nix and non-nix args: only nix files are checked" {
    echo 'hello' > "$TMP/readme.md"
    echo 'not a nix file' > "$TMP/data.json"
    cat > "$TMP/bad.nix" <<'NIX'
{
foo="bar";
}
NIX
    run lefthook-nixfmt --check "$TMP/readme.md" "$TMP/bad.nix" "$TMP/data.json"
    assert_failure
}

@test "mixed nix and non-nix args: passes when nix files are well-formatted" {
    echo 'hello' > "$TMP/readme.md"
    echo 'not a nix file' > "$TMP/data.json"
    cat > "$TMP/good.nix" <<'NIX'
{
  foo = "bar";
}
NIX
    run lefthook-nixfmt --check "$TMP/readme.md" "$TMP/good.nix" "$TMP/data.json"
    assert_success
}

@test "--format on already-formatted file exits 0" {
    cat > "$TMP/good.nix" <<'NIX'
{
  foo = "bar";
}
NIX
    cp "$TMP/good.nix" "$TMP/good.nix.orig"
    run lefthook-nixfmt --format "$TMP/good.nix"
    if [ "$status" -ne 0 ] && [[ "$output" == *"setOwnerAndGroup"* ]]; then
        skip "nixfmt atomic writes not supported in this environment"
    fi
    assert_success
    run diff "$TMP/good.nix" "$TMP/good.nix.orig"
    assert_success
}

@test "directory argument is skipped" {
    mkdir -p "$TMP/somedir"
    run lefthook-nixfmt --check "$TMP/somedir"
    assert_success
}

@test "directory with .nix extension is skipped" {
    mkdir -p "$TMP/fake.nix"
    run lefthook-nixfmt --check "$TMP/fake.nix"
    assert_success
}
