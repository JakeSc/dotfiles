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

local mod={}

local launcherModeBindings = {
    c = "Chrome",    -- "Chrome"
    r = "Simulator",
    a = "Activity Monitor",
    m = "Mail",
    p = "Maps",
    s = "Slack",
    e = "Messages",
    x = "Xcode",
    f = "Finder",
    l = "Calendar",
    u = "Sublime Text",
    z = "Zeplin",
    i = "iTunes",
    t = "Terminal",
}

-- bundleID ->
-- {
--     keyCode = keyCode,
--     iconElement = iconElement,
--     textElement = textElement
-- }
local appMap = {}

local appIconMap = {}
local appTextMap = {}

local hints = nil

local iconTextSpacingV = 10
local iconDimension = 96

function hintsFrame()
    local screenRect = hs.screen.mainScreen():fullFrame()
    local hintsWidth = 695
    local hintsHeight = 500
    local hintsX = screenRect.center.x - hintsWidth/2
    local hintsY = screenRect.center.y - hintsHeight/2

    return hs.geometry.rect(hintsX, hintsY, hintsWidth, hintsHeight)
end

function showHints()
    if hints == nil then
        local backgroundColor = {["red"]=0.0,["blue"]=0.0,["green"]=0.0,["alpha"]=0.3}
        hints = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
        hints:setRoundedRectRadii(10, 10)
        hints:setFill(true)
        hints:setStrokeColor(backgroundColor)
        hints:setFillColor(backgroundColor)
        hints:setStrokeWidth(8)
    end

    local hintsFrame = hintsFrame()

    hints:setFrame(hintsFrame)

    hints:show(0.2)

    local column = 0
    local row = 0

    for bundleID, appObject in pairs(appMap) do
        local key = appObject.keyCode
        local appName = appObject.appName
        local iconElement = appObject.iconElement
        local textElement = appObject.textElement

        local iconPoint = getIconPosition(row, column, hintsFrame)

        if iconPoint.wrapped then
            column = 0
            row = row + 1
        end

        drawHintIcon(iconElement, iconPoint.iconX, iconPoint.iconY, iconDimension)

        local appKeyTextWidth = 118
        local appKeyTextX = iconPoint.iconX + iconDimension - appKeyTextWidth/2
        local appKeyTextY = iconPoint.iconY + iconDimension + iconTextSpacingV

        drawHintIconCaption(textElement, appKeyTextX, appKeyTextY)

        column = column + 1
    end
end

function getIconPosition(row, column, hintsFrame)
    local paddingH = 20
    local paddingV = 10
    local iconSpacingH = 15
    local iconSpacingV = 15
    local textHeight = 40

    local iconX = hintsFrame.x + paddingH + (iconDimension + iconSpacingH) * column
    local iconY = hintsFrame.y + paddingV + (iconDimension + iconSpacingV + textHeight + iconTextSpacingV) * row

    local wrapped = false

    -- Check if the icon should wrap
    if (iconX + iconDimension) > (hintsFrame.bottomright.x - paddingH) then
        wrapped = true
        column = 0
        row = row + 1
        iconX = hintsFrame.x + paddingH + (iconDimension + iconSpacingH) * column
        iconY = hintsFrame.y + paddingV + (iconDimension + iconSpacingV + textHeight + iconTextSpacingV) * row
    end

    return {
        iconX = iconX,
        iconY = iconY,
        wrapped = wrapped
    }
end

function drawHintIcon(icon, x, y, iconDimension)
    if icon == nil then
        return
    end

    icon:setSize(hs.geometry.size(iconDimension, iconDimension))
    icon:setTopLeft(hs.geometry(x, y))
    icon:show(0.2)
end

function drawHintIconCaption(text, x, y)
    if text == nil then
        return
    end

    text:setTopLeft(hs.geometry(x, y))
    text:show(0.2)
end

function hideHints()
    if hints ~= nil then
        hints:hide(0.2)
    end

    for bundleID, appObject in pairs(appMap) do
        appObject.iconElement:hide(0.2)
        appObject.textElement:hide(0.2)
    end
end

local inLauncherMode = false

rcmd_down_listener = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local keyCode = event:getKeyCode()
    local characters = event:getCharacters()

    local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
    if keyCode == 80 and isRepeat == 0 and inLauncherMode == false then
        showHints()
        inLauncherMode = true
    end

    if inLauncherMode then
        return true
    end
end)

rcmd_up_listener = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
    local keyCode = event:getKeyCode()
    local characters = event:getCharacters()

    if keyCode == 80 then
        inLauncherMode = false
    end

    local appToLaunch = nil

    if inLauncherMode then
        appToLaunch = launcherModeBindings[characters]

        if appToLaunch ~= nil then
            local wasLaunched = hs.application.launchOrFocus(appToLaunch)

            if wasLaunched then
                hs.alert(appToLaunch)

                -- Try to populate the appMap object if it doesn't exist already
                local app = hs.application(appToLaunch)
                if app then
                    local bundleID = app:bundleID()
                    if bundleID then
                        local appElement = appMap[bundleID]
                        if appElement == nil then
                            print("Launcher Mode: Learning app:", appToLaunch, characters)

                            local appObject = generateAppMapElement(bundleID, appToLaunch, characters)
                            appMap[bundleID] = appObject
                        end
                    end
                end
            else
                print("Launcher Mode error: Failed to launch app: [", appToLaunch, "]")
            end
        end
    end

    hideHints()

    return appToLaunch ~= nil
end)

function generateAppMap()
    local bundleID = nil
    for key, appName in pairs(launcherModeBindings) do
        local app = hs.application(appName)
        if app then
            bundleID = app:bundleID()

            if bundleID then
                appMap[bundleID] = generateAppMapElement(bundleID, appName, key)
            else
                print("Launcher Mode error: Unable to load bundleID for app: ", appName)
            end
        else
            print("Launcher Mode error: Unable to find app: [", appName, "]")
        end
    end
end

function generateAppMapElement(bundleID, appName, keyCode)
    local iconElement = hs.drawing.appImage(hs.geometry.size(0, 0), bundleID)
    iconElement:setAlpha(0.3)

    local textElement = hs.drawing.text(hs.geometry.rect(0, 0, 100, 40), uppercaseChar(keyCode))
    textElement:setAlpha(0.3)

    return {
        keyCode = keyCode,
        appName = appName,
        iconElement = iconElement,
        textElement = textElement
    }
end

function uppercaseChar(lowercaseChar)
    return string.char(string.byte(lowercaseChar) - 32)
end

function lowercaseChar(lowercaseChar)
    return string.char(string.byte(lowercaseChar) + 32)
end

function mod.init()
    generateAppMap()

    rcmd_down_listener:start()
    rcmd_up_listener:start()
end

return mod

-------------------
--/Launcher Mode/--
-------------------

