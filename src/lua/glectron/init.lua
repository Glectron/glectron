Glectron = {}
Glectron.Applications = {}

Glectron.VNet = include("vnet.lua")

Glectron.Ready = false

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

local postEntityOK = false
local jsLibOK = false

local loadingQueue = {}
local payloadQueue = {}

local function initialize()
    if Glectron.Ready or not postEntityOK or not jsLibOK then return end
    Glectron.Ready = true

    for _,v in ipairs(payloadQueue) do
        RunString(v)
    end

    hook.Run("GlectronReady")
end

local jsLibCallback = include(GLECTRON_PATH .. "/interop/init.lua")
include(GLECTRON_PATH .. "/input.lua")
include(GLECTRON_PATH .. "/application.lua")

print("Glectron is loaded.")
hook.Run("GlectronLoaded")

local function receivePayload(key, content)
    if string.find(key, GLECTRON_PATH, 1, true) == 1 then
        -- Glectron internal resource
        if key == GLECTRON_PATH .. "/interop/js.lua" then
            local func = CompileString(content, "GlectronJavaScriptLibrary")
            jsLibCallback(func())
            jsLibOK = true
            initialize()
        else
            RunString(content)
        end
        return
    end
    local time = loadingQueue[key] and tostring(os.time() - loadingQueue[key]) or "(unknown)"
    if Glectron.Ready then
        chat.AddText(Color(102, 204, 255), "[Glectron] ", Color(27, 63, 155), key, Color(255, 255, 255), " retreived in ", Color(5, 181, 90), time, Color(255, 255, 255), " second(s), executing")
        RunString(content)
    else
        chat.AddText(Color(102, 204, 255), "[Glectron] ", Color(27, 63, 155), key, Color(255, 255, 255), " retreived in ", Color(5, 181, 90), time, Color(255, 255, 255), " second(s), queueing")
        table.insert(payloadQueue, content)
    end
    loadingQueue[key] = nil
end
Glectron.VNet.Watch("GlectronApp", function(pak)
    if string.find(pak.Data, GLECTRON_PATH, 1, true) == 1 then return end
    loadingQueue[pak.Data] = os.time()
    chat.AddText(Color(102, 204, 255), "[Glectron]", Color(255, 255, 255), " Retreving ", Color(27, 63, 155), pak.Data, Color(255, 255, 255), " from server...")
end)
Glectron.VNet.Watch("GlectronAppPayload", function(pak)
    local key = pak:String()
    local content = pak:String()
    receivePayload(key, content)
end)
hook.Add("ExpressLoaded", "Glectron", function()
    express.Receive("GlectronAppPayload", function(data)
        receivePayload(unpack(data))
    end)
end)

hook.Add("InitPostEntity", "Glectron", function()
    postEntityOK = true
    if Glectron:IsChromium() or GLECTRON_BYPASS_AWESOMIUM_CHECK then
        initialize()
    else
        Derma_Query("You are not using x86-64 or chromium branch, Glectron's garbage collecting won't be fully functional, this can lead to a memory leak.\nWould you like to continue using Glectron (and its apps)?", "Glectron", "Yes", initialize, "No")
    end
end)
