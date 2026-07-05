#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../lefthook.yml"
}

@test "pre-commit nixfmt uses bash scripts/lefthook/nixfmt-check.sh with staged_files" {
    run grep -A6 "^pre-commit:" "$CONFIG"
    assert_output --partial "bash scripts/lefthook/nixfmt-check.sh {staged_files}"
}

@test "pre-push nixfmt uses bash scripts/lefthook/nixfmt-check.sh with push_files" {
    run grep -A6 "^pre-push:" "$CONFIG"
    assert_output --partial "bash scripts/lefthook/nixfmt-check.sh {push_files}"
}

@test "pre-commit nixfmt has glob for nix files" {
    run grep -A6 "^pre-commit:" "$CONFIG"
    assert_output --partial '*.nix'
}

@test "pre-push nixfmt has glob for nix files" {
    run grep -A6 "^pre-push:" "$CONFIG"
    assert_output --partial '*.nix'
}

@test "no inline timeout in nixfmt commands" {
    run grep "timeout.*nixfmt" "$CONFIG"
    assert_failure
}

@test "no inline timeout in markdownlint commands" {
    run grep "timeout.*markdownlint" "$CONFIG"
    assert_failure
}

@test "pre-commit markdownlint uses bash scripts/lefthook/markdownlint-check.sh with staged_files" {
    run grep -A20 "^pre-commit:" "$CONFIG"
    assert_output --partial "bash scripts/lefthook/markdownlint-check.sh {staged_files}"
}

@test "pre-push markdownlint uses bash scripts/lefthook/markdownlint-check.sh with push_files" {
    run grep -A20 "^pre-push:" "$CONFIG"
    assert_output --partial "bash scripts/lefthook/markdownlint-check.sh {push_files}"
}

@test "pre-commit markdownlint has glob for md files" {
    run grep -A20 "^pre-commit:" "$CONFIG"
    assert_output --partial '*.md'
}

@test "pre-push markdownlint has glob for md files" {
    run grep -A20 "^pre-push:" "$CONFIG"
    assert_output --partial '*.md'
}
