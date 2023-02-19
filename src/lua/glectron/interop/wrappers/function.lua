local WRAPPER = {}

function WRAPPER:Transform(value, iLayer)
    if type(value) == "function" then
        -- Lua to JavaScript
        local jsSource = iLayer.m_Wrappers[value]
        if jsSource then
            -- This is a JavaScript function wrapper
            local obj = {
                ["_GTRON_WRAPPER_TYPE"] = "function",
                ["data"] = {
                    ["name"] = jsSource
                }
            }
            return util.TableToJSON(obj) -- Returns string
        else
            -- This is a Lua function
            local name = "FUNC_" .. util.Base64Encode(tostring(value))
            iLayer.m_Objects[name] = value
            local obj = {
                ["_GTRON_WRAPPER_TYPE"] = "luafunction",
                ["data"] = {
                    ["name"] = name
                }
            }
            return util.TableToJSON(obj) -- Returns string
        end
    end
    if type(value) == "table" then
        -- JavaScript to Lua
        if value._GTRON_WRAPPER_TYPE == "function" then
            -- This is a Lua function passed to JavaScript
            local name = value.data.name
            return iLayer.m_Objects[name] -- Returns function
        elseif value._GTRON_WRAPPER_TYPE == "jsfunction" then
            -- This is a JavaScript function
            local name = value.data.name
            table.insert(iLayer.m_WrapperNames, name)
            local function wrapper(...)
                -- TODO: Call JS function with parameter and return the value
            end
            iLayer.m_Wrappers[wrapper] = name
            return wrapper -- Returns function
        end
    end
end

return WRAPPER