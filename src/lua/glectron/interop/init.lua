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