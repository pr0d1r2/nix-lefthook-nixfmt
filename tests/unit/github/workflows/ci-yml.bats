#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  CONFIG="$BATS_TEST_DIRNAME/../../../../.github/workflows/ci.yml"
}

@test "guardrails job uses set-and-setting reusable workflow" {
  run grep "uses:" "$CONFIG"
  assert_output --partial "pr0d1r2/set-and-setting/.github/workflows/guardrails.yml"
}

@test "triggers on push to main" {
  run grep -A2 "push:" "$CONFIG"
  assert_output --partial "main"
}

@test "triggers on pull_request to main" {
  run grep -A2 "pull_request:" "$CONFIG"
  assert_output --partial "main"
}
