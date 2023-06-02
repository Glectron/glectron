Glectron.Interop.Wrappers = {}

for _,v in pairs(file.Find(GLECTRON_PATH .. "/interop/wrappers/*.lua", "LUA")) do
    local wrapper = include(GLECTRON_PATH .. "/interop/wrappers/" .. v)
    if wrapper then
        table.insert(Glectron.Interop.Wrappers, wrapper)
    end
end

local function sortWrappers()
    table.sort(Glectron.Interop.Wrappers, function(a, b)
        return (a.Priority or 0) < (b.Priority or 0)
    end)
end
sortWrappers()

function Glectron.Interop:AddWrapper(wrapper)
    table.insert(Glectron.Interop.Wrappers, wrapper)
    sortWrappers()
end