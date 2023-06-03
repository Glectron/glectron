Glectron = {}

local p = newproxy(true)
local pmeta = getmetatable(p)
function pmeta:__gc()
    -- TODO: Shutdown all loaded Glectron apps
end
local meta = {
    gc = p
}
setmetatable(Glectron, meta)

function Glectron:IsChromium()
    return string.find(BRANCH, "x86-64", 1, true) ~= nil or string.find(BRANCH, "chromium", 1, true) ~= nil
end

local function initialize()
    include(GLECTRON_PATH .. "/interop/init.lua")
    include(GLECTRON_PATH .. "/application.lua")
    
    print("Glectron is loaded.")
    hook.Run("GlectronLoaded")
end

if Glectron:IsChromium() then
    initialize()
else
    hook.Add("InitPostEntity", "GlectronDelayedLoad", function()
        Derma_Query("You are not using x86-64 or chromium branch, Glectron's garbage collecting won't be fully functional, this can lead to a memory leak.\nWould you like to continue using Glectron (and its apps)?", "Glectron", "Yes", initialize, "No")
    end)
end