local outlook = require('outlook_legacy_fontsize')

local function make_hs_stub()
  local calls = { key_strokes = {}, binds = {}, launches = 0 }

  local hs = {
    application = {
      launchOrFocus = function()
        calls.launches = calls.launches + 1
      end,
      frontmostApplication = function()
        return {
          name = function()
            return 'Microsoft Outlook'
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
        return 0
      end,
      doEvery = function()
        error('doEvery should not be called when Outlook is already frontmost')
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
end)
