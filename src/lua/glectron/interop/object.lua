local meta = {}

function meta:__tostring()
    return util.TableToJSON(self)
end

local INTEROP = Glectron.Interop

function INTEROP:IntoJSONObject(obj)
    setmetatable(obj, meta)
    return obj
end

function INTEROP:CreateInteropObject(type)
    local obj = {
        _G_InteropObj = true,
        _G_InteropType = type
    }
    setmetatable(obj, meta)
    return obj
end

function INTEROP:InteropObjectType(obj)
    if type(obj) ~= "table" then return nil end
    return obj._G_InteropType
end

function INTEROP:FromInteropObject(layer, obj)
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

function INTEROP:ToInteropObject(layer, obj)
    for _,v in ipairs(self.Wrappers) do
        local ret = v:To(layer, obj)
        if ret ~= nil then
            return ret
        end
    end
    return nil
end