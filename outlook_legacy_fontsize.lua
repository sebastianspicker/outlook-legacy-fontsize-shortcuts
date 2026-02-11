local M = {}

local DEFAULTS = {
  outlook_app_name = 'Microsoft Outlook',
  right_arrow_count = 2,
  timeout_seconds = 5,
  poll_interval_seconds = 0.1,
  on_timeout = nil,
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
  if type(value) ~= 'number' then
    return false
  end
  if value ~= value then
    return false
  end
  if math.huge and math.abs(value) == math.huge then
    return false
  end
  return value % 1 == 0
end

local function is_non_negative_integer(value)
  return is_integer(value) and value >= 0
end

local function is_valid_position(value)
  return is_integer(value) and value >= 0 and value <= 2
end

local function validate_config(config)
  if type(config.outlook_app_name) ~= 'string' then
    error('config.outlook_app_name must be a string', 3)
  end
  if type(config.poll_interval_seconds) ~= 'number' or config.poll_interval_seconds <= 0 then
    error('config.poll_interval_seconds must be a positive number', 3)
  end
  if type(config.timeout_seconds) ~= 'number' or config.timeout_seconds <= 0 then
    error('config.timeout_seconds must be a positive number', 3)
  end
  if not is_non_negative_integer(config.right_arrow_count) then
    error('config.right_arrow_count must be a non-negative integer', 3)
  end
  if type(config.delays_us) ~= 'table' then
    error('config.delays_us must be a table', 3)
  end
  for _, key in ipairs({ 'prefs_open', 'arrow', 'slider_set' }) do
    local v = config.delays_us[key]
    if type(v) ~= 'number' or v < 0 then
      error('config.delays_us.' .. key .. ' must be a non-negative number', 3)
    end
  end
  if config.on_timeout ~= nil and type(config.on_timeout) ~= 'function' then
    error('config.on_timeout must be a function or nil', 3)
  end
  if type(config.hotkeys) ~= 'table' then
    error('config.hotkeys must be a table', 3)
  end
  for name, hotkey in pairs(config.hotkeys) do
    if type(hotkey) ~= 'table' then
      error('config.hotkeys.' .. tostring(name) .. ' must be a table', 3)
    end
    if type(hotkey.mods) ~= 'table' then
      error('config.hotkeys.' .. tostring(name) .. '.mods must be a table', 3)
    end
    if hotkey.key == nil or (type(hotkey.key) ~= 'string' and type(hotkey.key) ~= 'number') then
      error('config.hotkeys.' .. tostring(name) .. '.key must be a non-nil string or number', 3)
    end
    if not is_valid_position(hotkey.position) then
      error('config.hotkeys.' .. tostring(name) .. '.position must be an integer in range 0..2', 3)
    end
  end
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
    if value ~= nil then
      if type(value) == 'table' and type(merged[key]) == 'table' then
        merged[key] = merge_tables(merged[key], value)
      elseif type(merged[key]) ~= 'table' or type(value) == 'table' then
        merged[key] = value
      end
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

local function noop_timer()
  return {
    stop = function() end,
    trigger = function() end,
  }
end

local function wait_for_frontmost(hs, app_name, poll_interval_seconds, timeout_seconds, on_ready, on_timeout)
  local front = hs.application.frontmostApplication()
  if front and front:name() == app_name then
    on_ready()
    return noop_timer()
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
      if type(on_timeout) == 'function' then
        on_timeout()
      end
    end
  end)
  return timer
end

function M.adjust_font_size(target_position, config, hs)
  hs = require_hs(hs)
  config = normalize_config(config)
  validate_config(config)

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
    end,
    config.on_timeout
  )
end

function M.setup(config, hs)
  hs = require_hs(hs)
  config = normalize_config(config)

  validate_config(config)

  -- Iterate in sorted order for deterministic binding order; callbacks use normalized config snapshot.
  local hotkey_names = {}
  for name in pairs(config.hotkeys) do
    hotkey_names[#hotkey_names + 1] = name
  end
  table.sort(hotkey_names, function(a, b)
    return tostring(a) < tostring(b)
  end)
  for _, name in ipairs(hotkey_names) do
    local hotkey = config.hotkeys[name]
    hs.hotkey.bind(hotkey.mods, hotkey.key, function()
      M.adjust_font_size(hotkey.position, config, hs)
    end)
  end

  return config
end

return M
