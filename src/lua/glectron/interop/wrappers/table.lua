local WRAPPER = {}

WRAPPER.Priority = 100

function WRAPPER:From(layer, obj)
    if type(obj) == "table" and not Glectron.Interop:InteropObjectType(obj) then
        local newTbl = {}
        for k, v in pairs(obj) do
            newTbl[k] = Glectron.Interop:FromInteropObject(layer, v)
        end
        return newTbl
    end
end

function WRAPPER:To(layer, obj)
    if type(obj) == "table" then
        if not Glectron.Interop:InteropObjectType(obj) then
            local newTbl = {}
            for k, v in pairs(obj) do
                newTbl[k] = (type(v) == "string" or Glectron.Interop:InteropObjectType(v)) and v or Glectron.Interop:ToInteropObject(layer, v)
            end
            return Glectron.Interop:IntoJSONObject(newTbl)
        end
    end
end

return WRAPPER