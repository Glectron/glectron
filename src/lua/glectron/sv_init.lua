Glectron = {}
Glectron.Ready = false

Glectron.VNet = include("vnet.lua")

util.AddNetworkString("GlectronApp")
util.AddNetworkString("GlectronAppPayload")

include("interop/js.lua")

local applications = {}
local applicationPayloads = {}
local applicationPayloadChecksums = {}

local fileReads = {}

function Glectron:GetApplicationByID(id)
    for _,v in pairs(applications) do
        if v.ID == id then return v end
    end
end

function Glectron:RegisterApplication(application)
    if not application.ID then error("No valid ID found for application.") end
    if not application.Name then error("Application must contain a name") end
    local payload = application.Payload
    if not payload then
        local lua = string.sub(debug.getinfo(2, "S").source, 2)
        local startPos, endPos = string.find(lua, "lua", 1, true)
        if startPos == nil or endPos == nil then error("Unable to traceback to Lua file.") end
        payload = string.sub(lua, endPos + 2)
        application.Payload = payload
    end
    if not file.Exists(payload, "LUA") then
        error("Payload file doesn't exist.")
    end
    local readId = os.time() .. ":" .. math.random(100, 200)
    fileReads[payload] = readId
    file.AsyncRead(payload, "LUA", function(_, _, status, data)
        if fileReads[payload] ~= readId then return end
        fileReads[payload] = nil
        if status ~= FSASYNC_OK then
            error("Unable to load application payload.")
        end
        if #data == 0 then error("Application " .. application.Name .. "(" .. application.ID .. ") has no payload.") end
        local checksum = util.SHA256(data)
        for k,v in pairs(applications) do
            if v.ID == application.ID then
                table.remove(applications, k)
                applicationPayloads[v.ID] = nil
                applicationPayloadChecksums[v.ID] = nil
            end
        end
        table.insert(applications, application)
        applicationPayloads[application.ID] = data
        applicationPayloadChecksums[application.ID] = checksum
        Glectron:SendApplication(application.ID, player.GetHumans())
    end)
end

function Glectron:SendApplication(id, targets)
    if type(targets) == "table" and #targets == 0 then return end
    local app = self:GetApplicationByID(id)
    if not app then error("Application ID is invalid.") end
    Glectron.VNet.CreatePacket("GlectronApp")
        :AddTargets(targets)
        :String(app.ID)
        :String(app.Name)
        :String(applicationPayloadChecksums[app.ID])
        :Send()
end

Glectron.VNet.Watch("GlectronAppPayload", function(pak)
    local ply = pak.Source
    local id = pak:String()
    local checksum = pak:String()
    if checksum ~= applicationPayloadChecksums[id] then
        Glectron:SendApplication(id, ply)
        return
    end
    if express then
        express.Send("GlectronAppPayload", {id, applicationPayloads[id], applicationPayloadChecksums[id]}, ply)
    else
        Glectron.VNet.CreatePacket("GlectronAppPayload")
            :AddTargets(ply)
            :String(id)
            :String(applicationPayloads[id])
            :String(applicationPayloadChecksums[id])
            :Send()
    end
end)

hook.Add("PlayerInitialSpawn", "Glectron", function(ply)
    for _,v in pairs(applications) do
        Glectron:SendApplication(v.ID, ply)
    end
end)

hook.Run("GlectronLoaded")
Glectron.Ready = true
hook.Run("GlectronReady")