local M = {}

local DEFAULTS = {
  outlook_app_name = 'Microsoft Outlook',
  right_arrow_count = 2,
  timeout_seconds = 5,
  poll_interval_seconds = 0.1,
  delays_us = {
    prefs_open = 700000,
    arrow = 150000,
    slider_set = 200000,
  },
  hotkeys = {
    larger = { mods = { 'ctrl', 'alt', 'cmd' }, key = 'G', position = 2 },
    standard = { mods = { 'ctrl', 'alt', 'cmd' }, key = 'K', position = 0 },
  },
}

local function is_integer(value)
  return type(value) == 'number' and value % 1 == 0
end

local function merge_tables(base, override)
  local merged = {}
  for key, value in pairs(base) do
    if type(value) == 'table' then
      merged[key] = merge_tables(value, {})
    else
      merged[key] = value
    end
  end
  if type(override) ~= 'table' then
    return merged
  end
  for key, value in pairs(override) do
    if type(value) == 'table' and type(merged[key]) == 'table' then
      merged[key] = merge_tables(merged[key], value)
    else
      merged[key] = value
    end
  end
  return merged
end

function M.defaults()
  return merge_tables(DEFAULTS, {})
end

local function require_hs(hs)
  if hs then
    return hs
  end
  local global_hs = rawget(_G, 'hs')
  if global_hs then
    return global_hs
  end
  error('Hammerspoon global `hs` not found; pass `hs` explicitly for tests.', 3)
end

local function normalize_config(config)
  return merge_tables(DEFAULTS, config or {})
end

local function wait_for_frontmost(hs, app_name, poll_interval_seconds, timeout_seconds, on_ready)
  local front = hs.application.frontmostApplication()
  if front and front:name() == app_name then
    on_ready()
    return nil
  end

  local start = hs.timer.secondsSinceEpoch()
  local timer
  timer = hs.timer.doEvery(poll_interval_seconds, function()
    local current_front = hs.application.frontmostApplication()
    if current_front and current_front:name() == app_name then
      if timer then
        timer:stop()
      end
      on_ready()
      return
    end

    if (hs.timer.secondsSinceEpoch() - start) >= timeout_seconds then
      if timer then
        timer:stop()
      end
    end
  end)
  return timer
end

function M.adjust_font_size(target_position, config, hs)
  hs = require_hs(hs)
  config = normalize_config(config)

  if not is_integer(target_position) or target_position < 0 or target_position > 2 then
    error('target_position must be an integer in range 0..2', 2)
  end

  hs.application.launchOrFocus(config.outlook_app_name)

  return wait_for_frontmost(
    hs,
    config.outlook_app_name,
    config.poll_interval_seconds,
    config.timeout_seconds,
    function()
      hs.eventtap.keyStroke({ 'cmd' }, ',')
      hs.timer.usleep(config.delays_us.prefs_open)

      for _ = 1, config.right_arrow_count do
        hs.eventtap.keyStroke({}, 'right')
        hs.timer.usleep(config.delays_us.arrow)
      end

      hs.eventtap.keyStroke({ 'ctrl' }, tostring(target_position))
      hs.timer.usleep(config.delays_us.slider_set)

      hs.eventtap.keyStroke({ 'cmd' }, 'w')
    end
  )
end

function M.setup(config, hs)
  hs = require_hs(hs)
  config = normalize_config(config)

  for _, hotkey in pairs(config.hotkeys) do
    hs.hotkey.bind(hotkey.mods, hotkey.key, function()
      M.adjust_font_size(hotkey.position, config, hs)
    end)
  end

  return config
end

return M
