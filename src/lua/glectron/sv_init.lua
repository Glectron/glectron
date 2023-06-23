Glectron = {}
Glectron.Ready = false

Glectron.VNet = include("vnet.lua")

util.AddNetworkString("GlectronApp")
util.AddNetworkString("GlectronAppPayload")

include("interop/js.lua")

local fatLuas = {}

hook.Add("PlayerInitialSpawn", "Glectron", function(ply)
    for k,_ in pairs(fatLuas) do
        Glectron:SendLua(k, ply)
    end
end)

function Glectron:SendLua(key, targets)
    local content = fatLuas[key]
    if not content then error("Invalid Lua key.") end
    self.VNet.SendString("GlectronApp", key, targets)
    if not express then
        self.VNet.CreatePacket("GlectronAppPayload")
            :AddTargets(targets)
            :String(key)
            :String(content)
            :Send()
    else
        if type(targets) == "table" then
            for _,v in pairs(targets) do
                express.Send("GlectronAppPayload", {key, content}, v)
            end
        else
            express.Send("GlectronAppPayload", {key, content}, targets)
        end
    end
end

function Glectron:AddCSFatLuaFile()
    local lua = string.sub(debug.getinfo(2, "S").source, 2)
    local startPos, endPos = string.find(lua, "lua", 1, true)
    if startPos == nil or endPos == nil then error("Unable to traceback to Lua file.") end
    local relativePath = string.sub(lua, endPos + 2)
    local content = file.Read(relativePath, "LUA")
    fatLuas[relativePath] = content
    local plys = player.GetHumans()
    if #plys > 0 then
        self:SendLua(relativePath, plys)
    end
end

hook.Run("GlectronLoaded")
Glectron.Ready = true
hook.Run("GlectronLoaded")