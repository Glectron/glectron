if SERVER then
    local function register()
        Glectron:RegisterApplication({
            ID = "glectron.javascript",
            Name = "Glectron JavaScript Library"
        })
    end
    if Glectron and Glectron.Ready then
        register()
    end
    hook.Add("GlectronLoaded", "GlectronJavaScriptLibrary", function()
        register()
    end)
    return
end
return util.Base64Decode([===[%GLECTRON_JS_LIBRARY%]===])