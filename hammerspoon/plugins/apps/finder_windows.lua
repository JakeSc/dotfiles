-- Bring all Finder windows forward when one gets activated

local mod={}

function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end
local appWatcher = hs.application.watcher.new(applicationWatcher)

function mod.init()
    appWatcher:start()
end

return mod
