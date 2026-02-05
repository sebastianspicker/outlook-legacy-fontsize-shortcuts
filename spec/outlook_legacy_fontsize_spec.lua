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
end)
