local WRAPPER = {}

WRAPPER.Priority = 100

function WRAPPER:From(_, obj)
    if type(obj) == "table" and not Glectron.Interop:InteropObjectType(obj) then
        return obj
    end
end

function WRAPPER:To(_, obj)
    if type(obj) == "table" then
        return util.TableToJSON(obj)
    end
end

return WRAPPER