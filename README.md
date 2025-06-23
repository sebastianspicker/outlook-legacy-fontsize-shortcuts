> **Deprecated**  
> This repository is no longer maintained.  
> Please see our new, actively-maintained version here:  
> 👉 [outlook-for-mac-fontsize-shortcuts](https://github.com/sebastianspicker/outlook-for-mac-fontsize-shortcuts))
> 

# Outlook Legacy Font Size Hotkeys with Hammerspoon

This project provides a simple, user-friendly way to control the font size in Outlook for Mac (Legacy) using global keyboard shortcuts. It leverages [Hammerspoon](https://www.hammerspoon.org/) to simulate UI interactions and adjust the in-app font slider, giving users a quick two-key shortcut for "Larger" and "Standard" font sizes without digging through menus.

## Problem Statement

* **Outlook Legacy** on macOS lacks a percentage-based zoom or free-form font-size adjustment in the message composer.
* The only built-in option is a coarse slider under **Outlook → Preferences → Fonts** with three positions: Standard, Large, Larger.
* Manually opening Preferences, navigating to the Fonts tab, and moving the slider is cumbersome, especially for non-technical users like teachers who need quick, repeatable shortcuts.

## Solution Overview

We use Hammerspoon—a lightweight, open-source automation tool—to:

1. **Launch or focus** the Outlook application.
2. **Open Preferences** via `Cmd + ,`.
3. **Navigate** to the Fonts tab using arrow keys.
4. **Set** the slider to the desired position (0 = Standard, 2 = Larger).
5. **Close** the Preferences window with `Cmd + W`.

This sequence is wrapped in a reusable Lua function, and bound to two hotkeys:

* `Ctrl + Alt + Cmd + G`: Set font size to *Larger* (`position = 2`).
* `Ctrl + Alt + Cmd + K`: Set font size to *Standard* (`position = 0`).

## Prerequisites

* **macOS** (tested on 12.0 Monterey and 13.0 Ventura)
* **Outlook for Mac (Legacy)** installed and signed in.
* **Hammerspoon** installed:

  ```bash
  brew install hammerspoon
  ```
* **Accessibility permissions** for Hammerspoon:
  System Settings → Privacy & Security → Accessibility → Enable Hammerspoon.

## Installation

1. **Clone** this repository:

   ```bash
   git clone https://github.com/your-org/outlook-font-shortcuts.git
   cd outlook-font-shortcuts
   ```
2. **Copy** the `init.lua` snippet into your Hammerspoon config folder:

   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```
3. **Reload** Hammerspoon config:
   Press `Ctrl + Cmd + R` or click the Hammerspoon icon and choose *Reload Config*.

## Configuration

* **Adjust `rightArrowCount`** if your Outlook Preferences tabs differ in order.
* **Tweak `hs.timer.usleep` delays** if your system is slower or faster.
* **Verify** tab labels and slider behavior with the macOS Accessibility Inspector if needed.

## How It Works

```lua
function adjustOutlookFontSize(targetPosition)
  hs.application.launchOrFocus("Microsoft Outlook")
  hs.timer.waitUntil(
    function()
      local front = hs.application.frontmostApplication()
      return front and front:name() == "Microsoft Outlook"
    end, nil, 5
  )
  hs.eventtap.keyStroke({"cmd"}, ",")
  hs.timer.usleep(700000)
  for i = 1, rightArrowCount do
    hs.eventtap.keyStroke({}, "right")
    hs.timer.usleep(150000)
  end
  hs.eventtap.keyStroke({"ctrl"}, tostring(targetPosition))
  hs.timer.usleep(200000)
  hs.eventtap.keyStroke({"cmd"}, "w")
end

hs.hotkey.bind({"ctrl","alt","cmd"}, "G", function() adjustOutlookFontSize(2) end)
hs.hotkey.bind({"ctrl","alt","cmd"}, "K", function() adjustOutlookFontSize(0) end)
```

1. **`adjustOutlookFontSize`**: Core function that runs the UI script.
2. **`rightArrowCount`**: Set at top of `init.lua` for tab navigation.
3. **Hotkeys**: Two distinct bindings for the two slider positions.

## Troubleshooting

* **Hotkeys not working?** Verify that Hammerspoon is running and has Accessibility permission.
* **Slider not moving?** Use the Accessibility Inspector to confirm the number of `right` key presses needed to reach the Fonts tab.
* **Delays too short/long?** Increase or decrease `usleep` durations to match your machine’s responsiveness.

## License

This project is licensed under the [MIT License](LICENSE).
