#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  CONFIG="$BATS_TEST_DIRNAME/../../../../.github/workflows/ci.yml"
}

@test "guardrails job uses the locked set-and-setting revision" {
  lock="$BATS_TEST_DIRNAME/../../../../flake.lock"
  sas_node="$(sed -n '/^    "root": {$/,/^    }/ s/.*"set-and-setting": "\([a-z0-9_-]*\)".*/\1/p' "$lock")"
  locked_rev="$(sed -n "/\"${sas_node}\": {/,/\"original\":/ s/.*\"rev\": \"\([0-9a-f]\{40\}\)\".*/\1/p" "$lock")"

  [ -n "$locked_rev" ]
  run grep "uses:" "$CONFIG"
  assert_output "    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@$locked_rev"
}

@test "triggers on push to main" {
  run grep -A2 "push:" "$CONFIG"
  assert_output --partial "main"
}

@test "triggers on pull_request to main" {
  run grep -A2 "pull_request:" "$CONFIG"
  assert_output --partial "main"
}
