# shellcheck shell=bash
# Lefthook-compatible nixfmt wrapper.
# Usage: lefthook-nixfmt [--check] file1.nix [file2.nix ...]
# Non-.nix files are skipped silently.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

mode="--check"
if [ "${1:-}" = "--check" ]; then
    shift
elif [ "${1:-}" = "--format" ]; then
    mode=""
    shift
fi

files=()
for f in "$@"; do
    [ -f "$f" ] || continue
    case "$f" in
        *.nix) files+=("$f") ;;
    esac
done

if [ ${#files[@]} -eq 0 ]; then
    exit 0
fi

exec nixfmt $mode "${files[@]}"
