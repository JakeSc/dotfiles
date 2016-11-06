-- From:
-- https://github.com/zzamboni/oh-my-hammerspoon

require("oh-my-hammerspoon")

omh_go({
    "apps.hammerspoon_toggle_console",
    "apps.hammerspoon_install_cli",
    "apps.hammerspoon_config_reload",
    "apps.launcher",
    "apps.finder_windows",
    "keyboard.vim_arrows",
    -- "windows.manipulation",
    "windows.grid",
    "windows.active_border",
    "misc.clipboard",
    "system.wifi_audio",
})




-- k = hs.hotkey.modal.new('cmd-shift', 'd')
-- function k:entered() hs.alert'Entered mode' end
-- function k:exited() hs.alert'Exited mode' end
-- k:bind('', 'escape', function() k:exit() end)
-- k:bind('', 'J', 'Pressed J',function() print'let the record show that J was pressed' end)

-- hs.hotkey.bind({"ctrl"}, "k", function()
--     local desktop = hs.window.desktop()
--     desktop:focus()
-- end)
