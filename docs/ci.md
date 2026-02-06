# CI Overview

## Workflows
### `ci` (push + pull_request)
Jobs:
- **Secret scan:** `scripts/secret_scan.sh`
- **OSV dependency scan:** reusable OSV-Scanner workflow (skips fork PRs)
- **Lua checks (5.1/5.4):** `make check` (luacheck + stylua --check + busted)

Hardening:
- Concurrency per workflow/branch with cancel-in-progress
- Job timeouts
- Toolchain pinned (Lua versions + Stylua version + LuaRocks package versions)
- LuaRocks cache (`.luarocks`, `lua_modules`) keyed by OS + Lua version + `Makefile`

## Local Reproduction
Preferred single command:
```bash
bash scripts/ci-local.sh
```

Manual steps:
```bash
make tools
make check
```

Optional (local dependency scan):
```bash
bash scripts/sca_check.sh
```

See `docs/RUNBOOK.md` for prerequisites.

## Secrets & Repo Settings
- No secrets required for CI.
- OSV-Scanner uploads SARIF when allowed (`security-events: write`). Fork PRs skip OSV to avoid permission failures.

## Extending CI
When adding new jobs:
1. Pin actions to stable major versions.
2. Use minimal `permissions`.
3. Add `timeout-minutes` and consider caching.
4. Keep PR checks fast; push heavier tasks to `workflow_dispatch` or scheduled runs.
