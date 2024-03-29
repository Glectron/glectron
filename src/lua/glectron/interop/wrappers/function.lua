local WRAPPER = {}

function WRAPPER:From(layer, obj)
    if type(obj) == "table" then
        local t = Glectron.Interop:InteropObjectType(obj)
        if t == "luafunction" then
            return layer.m_Objects[obj.ID]
        elseif t == "jsfunction" then
            local ptbl = {}
            local func = function(...)
                local p = ptbl -- Hack for function GC
                layer:CallJS(obj.ID, ...)
            end
            Glectron.Interop:BindGCForWrapper(layer, ptbl, obj.ID)
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
            return io
        else
            local strid = util.Base64Encode(tostring(obj), true)
            layer.m_Objects[strid] = obj
            local io = Glectron.Interop:CreateInteropObject("luafunction")
            io.ID = strid
            return io
        end
    end
end

return WRAPPER