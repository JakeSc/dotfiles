-- Vim Arrows

local mod={}

local move = function(direction) hs.eventtap.keyStroke({}, direction) end
local moveLeft = function() move("left") end
local moveDown = function() move("down") end
local moveUp = function() move("up") end
local moveRight = function() move("right") end

function mod.init()
	hs.hotkey.bind({"ctrl"}, "h", moveLeft, nil, moveLeft)
	hs.hotkey.bind({"ctrl"}, "j", moveDown, nil, moveDown)
	hs.hotkey.bind({"ctrl"}, "k", moveUp, nil, moveUp)
	hs.hotkey.bind({"ctrl"}, "l", moveRight, nil, moveRight)
end

return mod

