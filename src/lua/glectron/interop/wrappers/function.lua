local WRAPPER = {}

function WRAPPER:From(layer, obj)
    if type(obj) == "table" then
        local t = Glectron.Interop:InteropObjectType(obj)
        if t == "luafunction" then
            return layer.m_Objects[obj.ID]
        elseif t == "jsfunction" then
            local func = function(...)
                layer:CallJS(obj.ID, ...)
            end
            layer.m_Wrappers[func] = obj.ID
            return func
        end
    end
end

function WRAPPER:To(layer, obj)
    if type(obj) == "function" then
        if layer.m_Wrappers[obj] then
            -- This is a wrapper to JavaScript function
            local io = Glectron.Interop:CreateInteropObject("jsfunction")
            io.ID = layer.m_Wrappers[obj]
            return util.TableToJSON(io)
        else
            local strid = util.Base64Encode(tostring(obj), true)
            layer.m_Objects[strid] = obj
            local io = Glectron.Interop:CreateInteropObject("luafunction")
            io.ID = strid
            return util.TableToJSON(io)
        end
    end
end

return WRAPPER