# CI Audit

Date: 2026-02-06

## Inventory
**Workflow:** `ci` (`.github/workflows/ci.yml`)
- **Triggers:** `push`, `pull_request`
- **Concurrency:** per workflow/branch, cancel in progress
- **Jobs:**
  - **Secret scan:** repo-local patterns via `scripts/secret_scan.sh`
  - **OSV dependency scan:** OSV-Scanner reusable workflow (skips fork PRs)
  - **Lua checks (5.1/5.4):** `make check` across Lua 5.1 + 5.4
- **Pinned actions:**
  - `actions/checkout@v4` (commit pinned)
  - `leafo/gh-actions-lua@v11` (commit pinned)
  - `leafo/gh-actions-luarocks@v4` (commit pinned)
  - `JohnnyMorganz/stylua-action@v4` (commit pinned)
  - `actions/cache@v5` (commit pinned)
  - `google/osv-scanner-action@v2.3.2` (commit pinned)
- **Toolchain pins:**
  - Lua 5.1 + 5.4 (matrix)
  - Stylua `v2.3.1`
  - LuaRocks packages: `luacheck 1.2.0-1`, `busted 2.3.0-1`
- **Caching:** `.luarocks/`, `lua_modules/` keyed by OS + Lua version + `Makefile`
- **Timeouts:** 5–10 minutes per job
- **Artifacts:** none

## Recent Failures (Last 50 Runs)
No failed workflow runs observed via GitHub Actions API as of 2026-02-06.

## Failure Analysis & Fix Plan
| Workflow | Failure(s) | Root Cause | Fix Plan | Risk | How to Verify |
| --- | --- | --- | --- | --- | --- |
| `ci` | None observed in recent runs | N/A | N/A | N/A | Push/PR run should complete green |
| `ci` (preventive) | Potential OSV SARIF upload failure on fork PRs | Fork PR tokens are read-only; `security-events: write` may be rejected | Skip OSV job for fork PRs | Reduced OSV coverage for fork PRs | Open a fork PR and confirm OSV job is skipped, others run green |
| `ci` | Workflow invalid: `timeout-minutes` not allowed on reusable workflow job | `timeout-minutes` is unsupported on jobs that use `uses:` | Remove `timeout-minutes` from `osv_scan` job | None | Validate workflow on push/PR; CI should start successfully |
