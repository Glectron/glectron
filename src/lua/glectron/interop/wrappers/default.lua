local WRAPPER = {}

WRAPPER.Priority = 200

function WRAPPER:From(_, obj)
    return obj
end

function WRAPPER:To(layer, obj)
    return obj
end

return WRAPPER