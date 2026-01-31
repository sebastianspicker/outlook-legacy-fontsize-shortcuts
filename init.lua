local outlook = require('outlook_legacy_fontsize')

outlook.setup({
  right_arrow_count = 2,
  delays_us = {
    prefs_open = 700000,
    arrow = 150000,
    slider_set = 200000,
  },
})
