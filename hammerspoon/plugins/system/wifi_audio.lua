-- Mute volume when leaving home Wifi network
-- Revert to 25 when arriving home

local mod={}

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

function mod.init()
    wifiWatcher:start()
end

return mod

