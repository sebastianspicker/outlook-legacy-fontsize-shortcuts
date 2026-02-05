# REPO_MAP

## Overview
Hammerspoon Lua module that drives Outlook for Mac (Legacy) UI to set the font-size slider to preset positions, plus a sample `init.lua` that binds hotkeys. Includes unit tests with a stubbed `hs` API.

## Top-Level Layout
- `init.lua`  
  Sample Hammerspoon config that calls `outlook.setup(...)`.
- `outlook_legacy_fontsize.lua`  
  Core module: config defaults, hotkey binding, and UI automation logic.
- `spec/outlook_legacy_fontsize_spec.lua`  
  Tests using a stubbed `hs` table (busted).
- `Makefile`  
  Tooling and checks: `luacheck`, `stylua`, `busted`.

## Entry Points
- Runtime: `init.lua` (loaded by Hammerspoon).
- Module API:
  - `setup(config, hs)` binds hotkeys.
  - `adjust_font_size(target_position, config, hs)` drives UI flow.
  - `defaults()` returns default config.

## Key Flows
1) `setup` binds hotkeys and calls `adjust_font_size` on press.
2) `adjust_font_size`:
   - Launch/focus Outlook.
   - Waits until Outlook is frontmost.
   - Opens Preferences, navigates tabs, sets slider position, closes Preferences.

## Configuration Surface
- `outlook_app_name`, `right_arrow_count`, timing values, hotkeys list.

## Tests
- Focused on hotkey binding and keystroke order.
- Stubs `hs` to avoid UI dependencies.

## Hot Spots / Risks
- Timing and focus changes are OS/UI-dependent.
- Accessibility permissions required for Hammerspoon.
