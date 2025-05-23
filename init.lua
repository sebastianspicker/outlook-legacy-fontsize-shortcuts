-- Hammerspoon init.lua snippet for controlling Outlook Legacy font size via hotkeys
-- ============================================================================
-- This configuration defines two hotkeys:
--   ⌃⌥⌘G → Set Outlook font size to "Larger"
--   ⌃⌥⌘K → Set Outlook font size to "Standard"
--
-- Requirements:
-- 1. Hammerspoon installed and Accessibility enabled (System Settings → Privacy & Security → Accessibility → Hammerspoon).
-- 2. macOS Accessibility Inspector to verify UI navigation steps (tab positions, slider focus).
-- 3. Adjust `rightArrowCount` if the "Fonts" tab is not the 2nd or 3rd item from the default.
-- 4. Tune delays (`usleep` durations) based on system performance.
--
--------------------------------------------------------------------------------
function adjustOutlookFontSize(targetPosition)
    -- Activate or launch Microsoft Outlook
    hs.application.launchOrFocus("Microsoft Outlook")
    -- Wait for Outlook to be frontmost
    hs.timer.waitUntil(
        function()
            local front = hs.application.frontmostApplication()
            return front and front:name() == "Microsoft Outlook"
        end,
        function() end,
        5 -- timeout after 5 seconds
    )

    -- Open Preferences (⌘,)
    hs.eventtap.keyStroke({"cmd"}, ",")
    hs.timer.usleep(700000)  -- 0.7 seconds for the prefs window to appear

    -- Navigate to the "Fonts" tab
    -- The number of right arrows to send depends on your Outlook localization and tab order
    local rightArrowCount = 2
    for i = 1, rightArrowCount do
        hs.eventtap.keyStroke({}, "right")
        hs.timer.usleep(150000)  -- short pause between key events
    end

    -- Optionally, ensure the slider has focus
    -- If the slider does not get focus automatically, you can use:
    -- hs.eventtap.keyStroke({}, "tab")
    -- hs.timer.usleep(150000)

    -- Set the slider value via numeric key (0 = Standard, 1 = Larger, 2 = Largest)
    hs.eventtap.keyStroke({"ctrl"}, tostring(targetPosition))
    hs.timer.usleep(200000)

    -- Close Preferences (⌘W)
    hs.eventtap.keyStroke({"cmd"}, "w")
end

-- Hotkey: Control+Option+Command+G → Larger (position 2)
hs.hotkey.bind({"ctrl","alt","cmd"}, "G", function()
    adjustOutlookFontSize(2)
end)

-- Hotkey: Control+Option+Command+K → Standard (position 0)
hs.hotkey.bind({"ctrl","alt","cmd"}, "K", function()
    adjustOutlookFontSize(0)
end)
