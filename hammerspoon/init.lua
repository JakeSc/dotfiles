-- hs.hotkey.bind({"ctrl"}, "k", function()
--     local desktop = hs.window.desktop()
--     desktop:focus()
-- end)


-- Vim Arrows
hs.hotkey.bind({"ctrl"}, "h", function()
    hs.eventtap.keyStroke({}, "left")
end)
hs.hotkey.bind({"ctrl"}, "j", function()
    hs.eventtap.keyStroke({}, "down")
end)
hs.hotkey.bind({"ctrl"}, "k", function()
    hs.eventtap.keyStroke({}, "up")
end)
hs.hotkey.bind({"ctrl"}, "l", function()
    hs.eventtap.keyStroke({}, "right")
end)


-------------------
-- Launcher Mode --
-------------------

-- 
-- This feature assumes you have instructed Karabiner-Elements to map right_command to f19:
-- {
--     "profiles": [
--         {
--             "name": "Default profile",
--             "selected": true,
--             "simple_modifications": {
--                 "right_command": "f19"
--             }
--         }
--     ]
-- }
-- 

local launcherModeBindings = {
    x = "Xcode",
    r = "Simulator",
    s = "Slack",
    u = "Sublime Text",
    z = "Zeplin",
    m = "Mail",
    c = "Chrome",
    t = "Terminal",
    a = "Activity Monitor",
    f = "Finder",
    i = "iTunes",
    e = "Messages",
}

local inLauncherMode = false

f19down = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local keyCode = event:getKeyCode()
    local characters = event:getCharacters()

    local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
    if keyCode == 80 and isRepeat == 0 then
        inLauncherMode = true
    end

    if inLauncherMode then
        return true
    end

end)
f19down:start()

rcmd_tap = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
    local keyCode = event:getKeyCode()
    local characters = event:getCharacters()

    if keyCode == 80 then
        inLauncherMode = false
    end

    local appToLaunch = nil

    if inLauncherMode then
        appToLaunch = launcherModeBindings[characters]

        if appToLaunch ~= nil then
            hs.application.launchOrFocus(appToLaunch)
            hs.alert(appToLaunch)
        end
    end

    return appToLaunch ~= nil
end)
rcmd_tap:start()

-------------------
--/Launcher Mode/--
-------------------


function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- Bring all Finder windows forward when one gets activated
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end
local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()


-- Mute volume when leaving home Wifi network
-- Revert to 25 when arriving home
local wifiWatcher = nil
local homeSSID1 = "makelikeacroissant"
local homeSSID2 = "makelikeacroissant 5GHz"
local lastSSID = hs.wifi.currentNetwork()
function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    local changedToHome = (newSSID == homeSSID1 or newSSID == homeSSID2) and lastSSID ~= homeSSID1 and lastSSID ~= homeSSID2
    local changedFromHome = (newSSID ~= homeSSID1 and newSSID ~= homeSSID2) and (lastSSID == homeSSID1 and lastSSID == homeSSID2)

    if changedToHome then
        -- We just joined our home WiFi network
        hs.audiodevice.defaultOutputDevice():setVolume(25)
    elseif changedFromHome then
        -- We just departed our home WiFi network
        hs.audiodevice.defaultOutputDevice():setVolume(0)
    end

    lastSSID = newSSID
end
wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()


global_border = nil

function redrawBorder()
    win = hs.window.focusedWindow()
    if win ~= nil then
        top_left = win:topLeft()
        size = win:size()
        if global_border ~= nil then
            global_border:delete()
        end
        global_border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
        global_border:setStrokeColor({["red"]=0.5,["blue"]=0.7,["green"]=0.1,["alpha"]=0.3})
        global_border:setFill(false)
        global_border:setStrokeWidth(8)
        global_border:show()
    end
end

redrawBorder()

allwindows = hs.window.filter.new(nil)
allwindows:subscribe(hs.window.filter.windowCreated, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowFocused, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowMoved, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowUnfocused, function () redrawBorder() end)

-- k = hs.hotkey.modal.new('cmd-shift', 'd')
-- function k:entered() hs.alert'Entered mode' end
-- function k:exited() hs.alert'Exited mode' end
-- k:bind('', 'escape', function() k:exit() end)
-- k:bind('', 'J', 'Pressed J',function() print'let the record show that J was pressed' end)



