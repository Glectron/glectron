local WRAPPER = {}

WRAPPER.Priority = -10

function WRAPPER:From(_, obj)
    local t = type(obj)
    if
        t == "number" or
        t == "boolean" or
        t == "string"
    then
        return obj
    end
end

function WRAPPER:To(_, obj)
    local t = type(obj)
    if t == "string" then
        return "\"" .. obj:JavascriptSafe() .. "\""
    elseif t == "number" or t == "boolean" then
        return tostring(obj)
    end
end

return WRAPPER