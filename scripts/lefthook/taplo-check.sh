#!/usr/bin/env bash
set -euo pipefail

exec timeout "${LEFTHOOK_TAPLO_TIMEOUT:-30}" taplo check "$@"
