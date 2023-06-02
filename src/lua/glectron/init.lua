Glectron = {}

local meta = {
    __gc = function()
        -- TODO: Shutdown all loaded Glectron apps
    end
}
setmetatable(Glectron, meta)

include("interop/init.lua")
include("application.lua")

hook.Run("GlectronLoaded")