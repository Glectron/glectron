local WRAPPER = {}

function WRAPPER:Transform(value)
    local t = type(value)
    if
        t == "number" or
        t == "boolean"
    then
        return value
    end
    if t == "string" then
        return "\"" .. value:JavascriptSafe() .. "\""
    end
end

return WRAPPER