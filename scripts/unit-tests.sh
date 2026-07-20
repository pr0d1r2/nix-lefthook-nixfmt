# shellcheck shell=bash
# shellcheck disable=SC2154 # Variables are supplied by runCommand.
cd "$projectSrc" || exit
bats --recursive tests/unit
# shellcheck disable=SC2154 # Variable is supplied by runCommand.
touch "$out"
