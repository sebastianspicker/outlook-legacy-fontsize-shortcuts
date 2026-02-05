# RUNBOOK

Concrete, reproducible commands for setup, checks, and troubleshooting.

## Prereqs
- macOS (Hammerspoon only runs on macOS)
- `lua` (5.1 or 5.4 recommended)
- `luarocks`
- `stylua`
- Hammerspoon (runtime dependency for actual use, not required for tests)

Example install (macOS + Homebrew):
```bash
brew install lua luarocks stylua
brew install --cask hammerspoon
```

## Setup
```bash
make tools
```

## Format
```bash
make fmt
```

## Lint / Static Checks (SAST-lite)
```bash
make lint
```

## Typecheck
Not applicable (Lua).

## Build
Not applicable (library module + Hammerspoon config).

## Tests
```bash
make test
```

## Security Minimum
Secret scan (repo-local, high-signal patterns only):
```bash
bash scripts/secret_scan.sh
```

Dependency review (requires `osv-scanner` locally; CI runs OSV-Scanner either way):
```bash
bash scripts/sca_check.sh
```

## Fast Loop
```bash
make lint test
```

## Full Loop
```bash
make check
```

## Troubleshooting
- `luacheck: command not found`: run `make tools` to install local tools into `.luarocks/`.
- `stylua: command not found`: install `stylua` via your system package manager.
- Tests fail in CI: ensure `lua` is on PATH and `make tools` ran before `make test`.
