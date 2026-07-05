#!/usr/bin/env bash
set -euo pipefail

exec timeout "${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30}" markdownlint "$@"
