# CI Decision

**Decision:** FULL CI

## Why FULL CI?
- The repo contains executable Lua code, linting, formatting, and tests that run deterministically in GitHub-hosted runners.
- The checks are fast and do not require macOS UI access or production secrets.
- Existing test stubs keep Hammerspoon/Outlook out of the CI runtime, so Linux runners are sufficient.

## What Runs Where
- **Push + PR (default):**
  - Secret scan (repo-local patterns)
  - OSV dependency scan (skipped for fork PRs due to SARIF permission limits)
  - Lua checks: `luacheck`, `stylua --check`, `busted` on Lua 5.1 and 5.4

## Threat Model (CI)
- **Untrusted fork PRs:**
  - No secrets are required for CI jobs.
  - Workflow uses `pull_request` (not `pull_request_target`).
  - `permissions` are read-only except OSV’s SARIF upload, which is **skipped on fork PRs** to avoid token permission failures.
- **Dependency scanning:**
  - OSV runs from the base repo context and uploads SARIF when allowed.
- **Least privilege:**
  - Global `contents: read`; jobs only request what they need.

## If We Later Want “More Than FULL CI”
- Add macOS UI/integration tests for actual Hammerspoon/Outlook behavior.
  - Requires macOS runners with GUI access (likely self-hosted).
- Add release packaging/signing.
  - Requires secrets and protected environments.
- Add nightly heavy or flaky tests (scheduled) to keep PRs fast.
