# Archive Notice

This repository is **archived**. It is kept for reference and historical use only. No active development or support should be expected.

## Keep / Remove / Move Summary

### Keep (retained as-is)

| Path | Reason |
|------|--------|
| `init.lua` | Runnable Hammerspoon entry point; required for use. |
| `outlook_legacy_fontsize.lua` | Core module; all font-size logic lives here. |
| `spec/outlook_legacy_fontsize_spec.lua` | Test suite; needed for `make test` and CI. |
| `Makefile` | Build/test/lint; defines `tools`, `lint`, `fmt`, `fmt-check`, `test`, `check`, `clean`. |
| `.luacheckrc` | Lint config for Luacheck. |
| `.stylua.toml` | Format config for StyLua. |
| `.editorconfig` | Editor defaults. |
| `.github/workflows/ci.yml` | CI (Lua 5.1/5.4, lint, format check, tests). |
| `.gitignore` | Ignore patterns (e.g. `.luarocks/`, tooling caches). |
| `README.md` | User-facing docs: install, config, troubleshooting. |
| `LICENSE` | MIT license. |
| `SECURITY.md` | Unmaintained notice and how to report vulnerabilities. |

### Remove (WIP / process artifacts)

| Path | Reason |
|------|--------|
| Former audit tooling directory | Process/tooling for the automated audit loop. Not needed at runtime; **content** preserved under `docs/issue-audit/`. |
| (No other tracked WIP files) | `DECISIONS.md`, `FINDINGS.md`, `LOG.md`, `REFACTOR_PLAN.md`, `PHYSICS_AUDIT.md`, `validation.md` are listed in `.gitignore` only; they were never committed. |

### Move (preserved under new location)

| From | To | Reason |
|------|----|--------|
| Former audit tooling directory (content only) | `docs/issue-audit/` | **Issue Audit must be preserved.** Moved to a non-ignored path so it is versioned. Runner script and agent instructions were dropped; `README.md`, `prd.json`, and `progress.txt` kept. All text in English for GitHub. |

## Final Folder Structure

```
.
├── .editorconfig
├── .gitignore
├── .github/
│   └── workflows/
│       └── ci.yml
├── .luacheckrc
├── .stylua.toml
├── ARCHIVE.md          ← this file
├── LICENSE
├── Makefile
├── README.md
├── SECURITY.md
├── docs/
│   └── issue-audit/    ← Issue Audit preserved (do not delete)
│       ├── README.md
│       ├── prd.json
│       └── progress.txt
├── init.lua
├── outlook_legacy_fontsize.lua
└── spec/
    └── outlook_legacy_fontsize_spec.lua
```

Generated at archive time (e.g. `.luarocks/`, `lua_modules/`) are not in the repo; they are created by `make tools` and ignored by `.gitignore`.

## Validation Commands

All commands assume you are in the repository root.

### Build / install tools (one-time)

```bash
make tools
```

Installs `luacheck` and `busted` into `.luarocks/`.

### Lint

```bash
make lint
```

Runs Luacheck on `init.lua`, `outlook_legacy_fontsize.lua`, and `spec/`.

### Format check

```bash
make fmt-check
```

Checks that Lua is formatted with StyLua (no write). Use `make fmt` to reformat.

### Tests

```bash
make test
```

Runs Busted tests in `spec/`.

### Full check (lint + format check + tests)

```bash
make check
```

Use this to validate the repo before/after archive.

### Run (usage)

Not a single command: copy the Lua files into Hammerspoon’s config and reload:

```bash
cp init.lua outlook_legacy_fontsize.lua ~/.hammerspoon/
# Then in Hammerspoon: Reload Config (e.g. Ctrl+Cmd+R)
```

Requires macOS, Hammerspoon, and Outlook (Legacy) with Accessibility permission for Hammerspoon.

---

All documentation and file names in this archive are in English and ready for GitHub.
