if SERVER then
    for _, v in pairs(file.Find("gapp/*.lua", "LUA")) do
        AddCSLuaFile("gapp/" .. v)
        print("Added Glectron app", v, "to Lua list.")
    end
    AddCSLuaFile("gminimal/cl_init.lua")
end
if CLIENT then
    include("gminimal/cl_init.lua")
end