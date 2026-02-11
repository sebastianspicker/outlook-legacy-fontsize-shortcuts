local outlook = require('outlook_legacy_fontsize')

local function make_hs_stub(options)
  options = options or {}
  local calls = { key_strokes = {}, binds = {}, launches = 0, do_every = 0, timer_stopped = false }
  local frontmost_name = options.frontmost_name or 'Microsoft Outlook'
  local seconds = options.seconds or { 0 }
  local seconds_index = 1

  local hs = {
    application = {
      launchOrFocus = function()
        calls.launches = calls.launches + 1
      end,
      frontmostApplication = function()
        return {
          name = function()
            return frontmost_name
          end,
        }
      end,
    },
    eventtap = {
      keyStroke = function(mods, key)
        table.insert(calls.key_strokes, { mods = mods, key = key })
      end,
    },
    hotkey = {
      bind = function(mods, key, fn)
        table.insert(calls.binds, { mods = mods, key = key })
        assert(type(fn) == 'function')
      end,
    },
    timer = {
      usleep = function() end,
      secondsSinceEpoch = function()
        local value = seconds[seconds_index] or seconds[#seconds]
        seconds_index = seconds_index + 1
        return value
      end,
      doEvery = function(_, fn)
        if frontmost_name == 'Microsoft Outlook' then
          error('doEvery should not be called when Outlook is already frontmost')
        end

        calls.do_every = calls.do_every + 1
        local timer = {}
        function timer.stop()
          calls.timer_stopped = true
        end
        function timer.trigger()
          fn()
        end
        return timer
      end,
    },
  }

  return hs, calls
end

describe('outlook_legacy_fontsize', function()
  it('binds default hotkeys', function()
    local hs, calls = make_hs_stub()
    outlook.setup(nil, hs)
    assert.are.equal(2, #calls.binds)
  end)

  it('sends keystrokes in expected order', function()
    local hs, calls = make_hs_stub()
    outlook.adjust_font_size(2, { right_arrow_count = 2 }, hs)

    assert.are.equal(1, calls.launches)
    assert.are.equal(',', calls.key_strokes[1].key)
    assert.are.equal('right', calls.key_strokes[2].key)
    assert.are.equal('right', calls.key_strokes[3].key)
    assert.are.equal('2', calls.key_strokes[4].key)
    assert.are.equal('w', calls.key_strokes[5].key)
  end)

  it('rejects invalid target positions', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.adjust_font_size(3, nil, hs)
    end)
  end)

  it('times out when Outlook is never frontmost', function()
    local hs, calls = make_hs_stub({ frontmost_name = 'Other', seconds = { 0, 6 } })
    local timer = outlook.adjust_font_size(2, { timeout_seconds = 5 }, hs)

    assert.are.equal(1, calls.launches)
    assert.are.equal(0, #calls.key_strokes)
    assert.is_not_nil(timer)
    assert.are.equal(1, calls.do_every)

    timer:trigger()
    assert.is_true(calls.timer_stopped)
  end)

  it('calls on_timeout when timeout is reached', function()
    local hs, _ = make_hs_stub({ frontmost_name = 'Other', seconds = { 0, 6 } })
    local timeout_called = false
    local timer = outlook.adjust_font_size(2, {
      timeout_seconds = 5,
      on_timeout = function()
        timeout_called = true
      end,
    }, hs)
    assert.is_false(timeout_called)
    timer:trigger()
    assert.is_true(timeout_called)
  end)

  it('does not crash when config has nil delays_us or nil hotkeys (keeps defaults)', function()
    local hs, calls = make_hs_stub()
    outlook.setup({ delays_us = nil, hotkeys = nil }, hs)
    assert.are.equal(2, #calls.binds)
    outlook.adjust_font_size(0, { delays_us = nil }, hs)
    assert.are.equal(5, #calls.key_strokes)
  end)

  it('returns a timer-like object when Outlook is already frontmost', function()
    local hs = make_hs_stub()
    local result = outlook.adjust_font_size(2, nil, hs)
    assert.is_not_nil(result)
    assert.is_not_nil(result.stop)
    assert.is_not_nil(result.trigger)
  end)

  it('setup errors when hotkey has no position', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.setup({ hotkeys = { bad = { mods = { 'ctrl' }, key = 'X' } } }, hs)
    end)
  end)

  it('setup errors when hotkey position is out of range', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.setup(
        { hotkeys = { larger = { mods = { 'ctrl', 'alt', 'cmd' }, key = 'G', position = 5 } } },
        hs
      )
    end)
  end)

  it('setup errors when hotkey entry is not a table', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.setup({ hotkeys = { bad = 'invalid' } }, hs)
    end)
  end)

  it('setup errors when outlook_app_name is not a string', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.setup({ outlook_app_name = 123 }, hs)
    end)
  end)

  it('setup errors when delays_us field is not a number', function()
    local hs = make_hs_stub()
    assert.has_error(function()
      outlook.setup({ delays_us = { prefs_open = 'fast' } }, hs)
    end)
  end)

  it('setup succeeds with numeric hotkey names (sort uses tostring)', function()
    local hs, calls = make_hs_stub()
    outlook.setup({
      hotkeys = {
        [1] = { mods = { 'ctrl', 'alt', 'cmd' }, key = 'G', position = 2 },
        [2] = { mods = { 'ctrl', 'alt', 'cmd' }, key = 'K', position = 0 },
      },
    }, hs)
    assert.are.equal(4, #calls.binds)
  end)
end)
