Glectron.Interop = {}

include("wrappers.lua")
include("layer.lua")

function Glectron.Interop:CreateInteropObject(type)
    return {
        _G_InteropObj = true,
        _G_InteropType = type
    }
end

function Glectron.Interop:InteropObjectType(obj)
    return obj._G_InteropType
end

function Glectron.Interop:FromInteropObject(layer, obj)
    if type(obj) == "string" and string.StartsWith(obj, "!GOBJ!") then
        obj = util.JSONToTable(string.sub(obj, 7))
    end
    for _,v in ipairs(self.Wrappers) do
        local ret = v:From(layer, obj)
        if ret ~= nil then
            return ret
        end
    end
    return nil
end

function Glectron.Interop:ToInteropObject(layer, obj)
    for _,v in ipairs(self.Wrappers) do
        local ret = v:To(layer, obj)
        if ret ~= nil then
            return ret
        end
    end
    return "null"
end

function Glectron.Interop:BuildJavascriptCallSignature(layer, func, ...)
    local parameters = {...}
    local p = ""
    for _,v in ipairs(parameters) do
        p = p .. self:ToInteropObject(layer, v) .. ","
    end
    p = string.sub(p, 1, #p - 1)
    return func .. "(" .. p .. ")"
end

function Glectron.Interop:ListenForGC(obj, callback)
    local p = newproxy(true)
    local pmeta = getmetatable(p)
    function pmeta:__gc()
        callback()
    end
    local meta = getmetatable(obj) or {}
    meta["_g_gc_proxy"] = p
    setmetatable(obj, meta)
end

function Glectron.Interop:BindGCForWrapper(layer, obj, id)
    self:ListenForGC(obj, function()
        layer:Collect(id)
    end)
end