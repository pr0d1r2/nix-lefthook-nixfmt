#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="$BATS_TEST_DIRNAME/../../lefthook-repo.yml"
}

@test "runs markdownlint in both hook phases" {
    run grep -F 'run: bash scripts/lefthook/markdownlint-check.sh {staged_files}' "$CONFIG"
    assert_success
    run grep -F 'run: bash scripts/lefthook/markdownlint-check.sh {push_files}' "$CONFIG"
    assert_success
}

@test "runs nixfmt in both hook phases" {
    run grep -F 'run: bash scripts/lefthook/nixfmt-check.sh {staged_files}' "$CONFIG"
    assert_success
    run grep -F 'run: bash scripts/lefthook/nixfmt-check.sh {push_files}' "$CONFIG"
    assert_success
}

@test "keeps taplo in both hook phases" {
    run grep -F 'run: bash scripts/lefthook/taplo-check.sh {staged_files}' "$CONFIG"
    assert_success
    run grep -F 'run: bash scripts/lefthook/taplo-check.sh {push_files}' "$CONFIG"
    assert_success
}
