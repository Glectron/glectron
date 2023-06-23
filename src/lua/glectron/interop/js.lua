if SERVER then
    if Glectron and Glectron.Ready then
        Glectron:AddCSFatLuaFile()
    end
    hook.Add("GlectronLoaded", "GlectronJavaScriptLibrary", function()
        Glectron:AddCSFatLuaFile()
    end)
    return
end
return util.Base64Decode([===[%GLECTRON_JS_LIBRARY%]===])