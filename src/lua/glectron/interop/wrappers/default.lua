local WRAPPER = {}

WRAPPER.Priority = 200

function WRAPPER:From(_, obj)
    return obj
end

function WRAPPER:To(layer, obj)
    return type(obj) == "table" and util.TableToJSON(obj) or tostring(obj)
end

return WRAPPER