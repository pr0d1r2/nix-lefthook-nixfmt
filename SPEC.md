## §D — Description

nix-lefthook-nixfmt is a Nix flake that provides a lefthook-compatible
[nixfmt](https://github.com/NixOS/nixfmt) wrapper for git pre-commit and
pre-push hooks. It filters `.nix` files from staged/pushed file lists, runs
`nixfmt --check` (or `--format`) on them, and exits 0 when no `.nix` files
are present. Consumers integrate it either as a lefthook remote (recommended,
zero flake dependency) or as a flake input added to their devShell. The
project targets Nix developers who enforce formatting in CI and local hooks
across Linux and macOS on both amd64 and arm64.

## §V — Invariants

1. `lefthook-nixfmt` with zero arguments must exit 0.
2. Non-existent files and non-`.nix` files must be silently skipped (exit 0).
3. Default mode is `--check`; `--format` reformats in place and exits 0.
4. A badly-formatted `.nix` file must cause a non-zero exit in `--check` mode.
5. The flake must evaluate on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
6. CI must pass on both `ubuntu-latest` and `macos-latest`.
7. Every shell script must have 1-to-1 bats unit test coverage (`tests/unit/<name>.bats`).
8. All lefthook commands must have a timeout (per-hook `$LEFTHOOK_<TOOL>_TIMEOUT`, default 30 s).
9. Lefthook checks must appear in both `pre-commit` and `pre-push`.
10. No embedded shell in Nix files — shell logic is extracted to `.sh` files.
11. Shell scripts must not define functions; factor into separate scripts.
12. Shell scripts are invoked via `bash script.sh`, never `./script.sh`.
13. Every tracked file type must have a linter in `lefthook.yml`.
14. EditorConfig enforces: UTF-8, LF line endings, 2-space indent,
    trailing-whitespace trim, final newline.

## §I — Interfaces

### CLI

```
lefthook-nixfmt [--check | --format] [file ...]
```

- `--check` (default) — verify formatting, exit non-zero on violation.
- `--format` — rewrite files in place.
- Non-`.nix` and non-existent paths are silently ignored.
- Exit 0 when the filtered file list is empty.

### Nix flake outputs

| Output | Type | Description |
|---|---|---|
| `packages.<system>.default` | derivation | `writeShellApplication` wrapping `lefthook-nixfmt.sh` with `nixfmt` on `PATH` |
| `devShells.<system>.default` | mkShell | Interactive shell: all linter wrappers, bats, lefthook auto-install via `dev.sh` |
| `devShells.<system>.ci` | mkShell | CI shell: same packages, no shell hook, `BATS_LIB_PATH` env var set |

### Configuration files

| File | Format | Purpose |
|---|---|---|
| `lefthook.yml` | YAML | Local hook config with 15 remote linter repos + inline nixfmt commands |
| `lefthook-remote.yml` | YAML | Consumed by other repos via lefthook remote; uses `lefthook-nixfmt` wrapper |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits (default 4096 bytes) |
| `.yamllint.yml` | YAML | yamllint config: disable line-length, disable truthy key check |
| `.markdownlint.yml` | YAML | markdownlint config: disable MD013 (line length) |
| `.editorconfig` | INI | Editor style: UTF-8, LF, 2-space indent |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `LEFTHOOK_NIXFMT_TIMEOUT` | `30` | Timeout in seconds for the nixfmt hook |
| `LEFTHOOK_MARKDOWNLINT_TIMEOUT` | `30` | Timeout in seconds for the markdownlint hook |
| `LEFTHOOK_TAPLO_TIMEOUT` | `30` | Timeout in seconds for the taplo hook |
| `BATS_LIB_PATH` | set by `dev.sh` / `ci` shell | Path to bats helper libraries |

### Dev shell hook (`dev.sh`)

Sourced by `shellHook` in the default devShell. Sets `BATS_LIB_PATH` and
runs `lefthook install` if `.git/hooks/pre-commit` is missing.

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T10 | Create `scripts/lefthook/nixfmt-check.sh` (wraps `timeout ${LEFTHOOK_NIXFMT_TIMEOUT:-30} nixfmt --check "$@"`) with TDD bats test at `tests/unit/scripts/lefthook/nixfmt-check.bats`; must pass shellcheck |
| `x` | T11 | Update `lefthook.yml` pre-commit and pre-push nixfmt commands to `bash scripts/lefthook/nixfmt-check.sh {staged_files}` / `{push_files}` replacing inline shell (depends on T10) |
| `x` | T01 | Add `watch_file` entries to `.envrc` for `flake.nix`, `flake.lock`, `dev.sh`, and `lefthook-nixfmt.sh` per direnv skill |
| `x` | T02 | Extract inline `nixfmt --check` commands in `lefthook.yml` pre-commit/pre-push to a shell script per lefthook modularity skill |
| `x` | T03 | Upgrade `actions/checkout` in `update-pins.yml` from v4 to v6 to match `ci.yml` |
| `x` | T04 | Add markdownlint lefthook check for `*.md` files (config already exists at `.markdownlint.yml`) |
| `x` | T05 | Add TOML linter (e.g. `taplo`) lefthook check for `.rtk/filters.toml` |
| `x` | T06 | Add edge-case bats tests for `lefthook-nixfmt`: mixed nix/non-nix args, `--format` on already-formatted file, directory argument |
| `.` | T07 | Add `nix flake check` to CI workflow (currently only run in `update-pins.yml`) |
| `.` | T08 | Pin remote lefthook configs to specific refs/SHAs instead of `main` for reproducibility |
| `.` | T09 | Add `BATS_LIB_PATH` to the `ci` devShell's env so CI scripts don't need to set it separately |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` directives** — The `.envrc` contains only `use flake`. Per the project's own direnv skill, it should watch `flake.nix`, `flake.lock`, and dependent files so `direnv` reloads when they change. Without this, developers must manually `direnv reload` after flake changes.

2. **Inconsistent `actions/checkout` versions** — `ci.yml` uses `actions/checkout@v6` while `update-pins.yml` uses `@v4`.

3. **Local vs. remote nixfmt invocation mismatch** — `lefthook.yml` runs raw `nixfmt --check {staged_files}` bypassing the wrapper, while `lefthook-remote.yml` (for consumers) uses `lefthook-nixfmt`. The README documents this as intentional (avoiding circular flake deps), but it means the wrapper's file-filtering logic (skip non-`.nix`, skip missing) is not exercised by the project's own hooks.

4. **`ci` devShell sets `BATS_LIB_PATH` as env, `default` sets it in shellHook** — The `ci` shell uses `BATS_LIB_PATH = "${batsWithLibs}/share/bats"` as an environment variable, while the `default` shell substitutes `@BATS_LIB_PATH@` in `dev.sh`. The value is correct in both but the `ci` shell path differs from what `dev.sh` produces (`…/share/bats` vs the template which appends `/share/bats` to the raw derivation path). These resolve to the same directory only because `batsWithLibs` output is the bats prefix. If the derivation layout changes, they could diverge.

5. **Remote lefthook configs pinned to `main`** — All 15 remote lefthook repos in `lefthook.yml` use `ref: main`, meaning hook behavior can change without any local change. Pinning to SHAs or tags would improve reproducibility.

6. **`SPEC.md` 3-space continuation indentation fails editorconfig-checker** — Numbered list continuation lines used 3-space indentation to align with list text, violating the `.editorconfig` `indent_size = 2` rule. Fixed by unwrapping continuations to single lines (MD013/line-length is already disabled).

7. **`shellcheck` not directly available in CI devShell** — The `ci` devShell only exposed `shellcheck` as a `runtimeInput` inside the `lefthook-shellcheck` wrapper, not on the top-level PATH. The bats test `passes shellcheck` in `nixfmt-check.bats` calls `shellcheck` directly, so it failed in CI with "command not found". Fixed by adding `pkgs.shellcheck` to `ciCommon` in `flake.nix`.

8. **Orphaned `update-pins-yml.bats` after dropping `update-pins.yml` workflow** — The commit that removed `.github/workflows/update-pins.yml` ("drop update-pins cron") left its test file `tests/unit/github/workflows/update-pins-yml.bats` in place, causing 5 test failures (grep against a non-existent file). Fixed by removing the orphaned test file.
