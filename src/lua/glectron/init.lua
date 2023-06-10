Glectron = {}

local p = newproxy(true)
local pmeta = getmetatable(p)
function pmeta:__gc()
    for _,v in pairs(Glectron.Applications or {}) do
        v:_Shutdown() -- Do force shutdown
    end
end
local meta = {
    gc = p
}
setmetatable(Glectron, meta)

function Glectron:IsChromium()
    return string.find(BRANCH, "x86-64", 1, true) ~= nil or string.find(BRANCH, "chromium", 1, true) ~= nil
end

local glectronOK = false
local ipeOK = false
hook.Add("InitPostEntity", "Glectron", function()
    ipeOK = true
    if glectronOK then
        hook.Run("GlectronReady")
    end
end)

local function initialize()
    Glectron.Applications = {}

    include(GLECTRON_PATH .. "/interop/init.lua")
    include(GLECTRON_PATH .. "/input.lua")
    include(GLECTRON_PATH .. "/application.lua")
    
    print("Glectron is loaded.")
    glectronOK = true
    hook.Run("GlectronLoaded")
    if ipeOK then
        hook.Run("GlectronReady")
    end
end

if Glectron:IsChromium() then
    initialize()
else
    hook.Add("InitPostEntity", "GlectronDelayedLoad", function()
        Derma_Query("You are not using x86-64 or chromium branch, Glectron's garbage collecting won't be fully functional, this can lead to a memory leak.\nWould you like to continue using Glectron (and its apps)?", "Glectron", "Yes", initialize, "No")
    end)
end