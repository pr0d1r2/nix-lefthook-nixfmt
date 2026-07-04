#!/usr/bin/env bash
set -euo pipefail

exec timeout "${LEFTHOOK_NIXFMT_TIMEOUT:-30}" nixfmt --check "$@"
