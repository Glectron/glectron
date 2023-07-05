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

function Glectron:ChatMsg(...)
    chat.AddText(Color(102, 204, 255), "[Glectron]", Color(255, 255, 255), ...)
end

function Glectron:IsChromium()
    return string.find(BRANCH, "x86-64", 1, true) ~= nil or string.find(BRANCH, "chromium", 1, true) ~= nil
end

local postEntityOK = false
local jsLibOK = false

local loadingQueue = {}
local applicationQueue = {}
local runApplication -- Forward declare

local function initialize()
    if Glectron.Ready or not postEntityOK or not jsLibOK then return end
    Glectron.Ready = true

    for _,v in ipairs(applicationQueue) do
        runApplication(unpack(v))
    end

    hook.Run("GlectronReady")
end

local jsLibCallback = include(GLECTRON_PATH .. "/interop/init.lua")
include(GLECTRON_PATH .. "/cache.lua")
include(GLECTRON_PATH .. "/input.lua")
include(GLECTRON_PATH .. "/application.lua")

file.CreateDir("glectron/cache")

print("Glectron is loaded.")
hook.Run("GlectronLoaded")

local applications = {}

function Glectron:GetApplicationByID(id)
    for _,v in pairs(applications) do
        if v.ID == id then return v end
    end
end

runApplication = function(id, name, content)
    local isGlectronInternal = string.StartsWith(id, "glectron.")
    if isGlectronInternal then
        -- Glectron internal resource
        if id == "glectron.javascript" then
            local func = CompileString(content, "GlectronJavaScriptLibrary")
            jsLibCallback(func())
            jsLibOK = true
            initialize()
            return
        end
    elseif not Glectron.Ready then
        table.insert(applicationQueue, {id, name, content})
    else
        Glectron:ChatMsg("Running application ", name)
    end
    local err = RunString(content, id, false)
    if err then
        Glectron:ChatMsg("Unable to run application ", name, "(", id, ").")
        error("Unable to run application " .. name .. "(" .. id .. "): " .. err)
    end
end

local function handlePayload(id, payload, checksum)
    local app = Glectron:GetApplicationByID(id)
    if not app then error("Unknown application.") end
    Glectron.Cache:WriteCache(payload, checksum)
    runApplication(id, app.Name, payload)
end

local function requestPayload(id, name, checksum)
    for k,v in pairs(applications) do
        if v.ID == id then
            table.remove(applications, k)
        end
    end
    table.insert(applications, {
        ID = id,
        Name = name
    })
    Glectron.VNet.CreatePacket("GlectronAppPayload")
        :AddServer()
        :String(id)
        :String(checksum)
        :Send()
end

Glectron.VNet.Watch("GlectronApp", function(pak)
    local id = pak:String()
    local name = pak:String()
    local checksum = pak:String()

    Glectron.Cache:IsCached(checksum, function(result, data)
        if result then
            Glectron.Cache:TouchCache(checksum)
            runApplication(id, name, data)
        else
            if not string.StartsWith(id, "glectron.") then
                Glectron:ChatMsg("Retreving application ", name, " from server...")
            end
            requestPayload(id, name, checksum)
        end
    end)
end)
Glectron.VNet.Watch("GlectronAppPayload", function(pak)
    handlePayload(
        pak:String(), -- ID
        pak:String(), -- Name
        pak:String() -- Checksum
    )
end)
hook.Add("ExpressLoaded", "Glectron", function()
    express.Receive("GlectronAppPayload", function(data)
        handlePayload(unpack(data))
    end)
end)

hook.Add("InitPostEntity", "Glectron", function()
    if Glectron:IsChromium() or GLECTRON_BYPASS_AWESOMIUM_CHECK then
        postEntityOK = true
        initialize()
    else
        Derma_Query("You are not using x86-64 or chromium branch, Glectron's garbage collecting won't be fully functional, this can lead to a memory leak.\nWould you like to continue using Glectron (and its apps)?", "Glectron", "Yes", function()
            postEntityOK = true
            initialize()
        end, "No")
    end
end)
