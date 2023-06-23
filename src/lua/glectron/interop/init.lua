Glectron.Interop = {}

include("wrappers.lua")
local jsLibCallback = include("layer.lua")
include("object.lua")

function Glectron.Interop:BuildJavascriptCallSignature(layer, func, ...)
    local parameters = {...}
    local p = ""
    for _,v in ipairs(parameters) do
        p = p .. tostring(self:ToInteropObject(layer, v) or "null") .. ","
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

return jsLibCallback