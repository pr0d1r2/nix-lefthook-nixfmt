#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  CONFIG="$BATS_TEST_DIRNAME/../../../../.github/workflows/ci.yml"
}

@test "build-linux job runs nix flake check" {
  run grep -A6 "build-linux:" "$CONFIG"
  assert_output --partial "nix flake check"
}

@test "build-macos job runs nix flake check" {
  run grep -A7 "build-macos:" "$CONFIG"
  assert_output --partial "nix flake check"
}
