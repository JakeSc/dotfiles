local mod={}

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
        global_border:show(0.2)
    elseif global_border ~= nil then
        global_border:hide(0.2)
    end
end

local wf = hs.window.filter

function mod.init()
    redrawBorder()
    allwindows = wf.new(nil)
    allwindows:subscribe(wf.windowCreated, function () redrawBorder() end)
    allwindows:subscribe(wf.windowFocused, function () redrawBorder() end)
    allwindows:subscribe(wf.windowMoved, function () redrawBorder() end)
    allwindows:subscribe(wf.windowUnfocused, function () redrawBorder() end)
    -- allwindows:subscribe(wf.windowMinimized, function () redrawBorder() end)
end

return mod
