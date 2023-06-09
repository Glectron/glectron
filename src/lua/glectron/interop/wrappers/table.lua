local WRAPPER = {}

WRAPPER.Priority = 100

local function toInteropObject(layer, val)
    local result = Glectron.Interop:ToInteropObject(layer, val)

    local num = tonumber(result)
    if num then return num end

    if result == "true" then return true end
    if result == "false" then return false end

    local tbl = util.JSONToTable(result)
    if tbl then return tbl end

    return result
end

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
                newTbl[k] = Glectron.Interop:InteropObjectType(v) and v or toInteropObject(layer, v)
            end
            return util.TableToJSON(newTbl)
        end
    end
end

return WRAPPER