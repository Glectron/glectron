local __glectron_js_library__ = util.Base64Decode([===[%GLECTRON_JS_LIBRARY%]===])

local InteropLayer = {}
InteropLayer.__index = InteropLayer

function InteropLayer:Create(app)
    local layer = {}
    setmetatable(layer, InteropLayer)

    layer.m_App = app
    layer.m_Wrappers = {}
    layer.m_Objects = {}

    local weak = {}
    weak.__mode = "k"
    setmetatable(layer.m_Wrappers, weak)

    return layer
end

function InteropLayer:Setup()
    local dhtml = self.m_App.m_DHTML

    if Glectron:IsChromium() then
        dhtml:RunJavascript("window._GLECTRON_CHROMIUM_=true")
    end
    dhtml:RunJavascript(__glectron_js_library__)

    dhtml:AddFunction("_glectron_lua_", "call", function(id, ...)
        local func = self.m_Objects[id]
        if not func then
            error("invalid func id")
        end
        local parameters = {...}
        local p = {}
        for _,v in ipairs(parameters) do
            table.insert(p, Glectron.Interop:FromInteropObject(self, v))
        end
        func(unpack(p))
    end)
    dhtml:AddFunction("_glectron_lua_", "collect", function(id)
        self.m_Objects[id] = nil
        collectgarbage()
    end)
end

function InteropLayer:Reset()
    self.m_Wrappers = {}
    self.m_Objects = {}

    local weak = {}
    weak.__mode = "k"
    setmetatable(self.m_Wrappers, weak)

    collectgarbage()
end

function InteropLayer:RunJavascriptFunction(func, ...)
    if not self.m_App.m_DHTML then return end
    self.m_App.m_DHTML:RunJavascript(Glectron.Interop:BuildJavascriptCallSignature(self, func, ...))
end

function InteropLayer:AddFunction(path, func)
    self:RunJavascriptFunction("_glectron_js_.registerLuaFunction", path, func)
end

function InteropLayer:Collect(id)
    self:RunJavascriptFunction("_glectron_js_.collect", id)
end

function InteropLayer:CallJS(func, ...)
    self:RunJavascriptFunction("_glectron_js_.call", func, ...)
end

function InteropLayer:FireEvent(event, data)
    self:RunJavascriptFunction("_glectron_js_.fireEvent", event, data)
end

Glectron.InteropLayer = InteropLayer