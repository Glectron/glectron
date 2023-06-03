local __glectron_js_library__ = [[%GLECTRON_JS_LIBRARY%]]

local InteropLayer = {}
InteropLayer.__index = InteropLayer

function InteropLayer:Create(app)
    local layer = {}
    setmetatable(layer, InteropLayer)

    layer.m_App = app
    layer.m_WrapperNames = {}
    layer.m_Wrappers = {}
    layer.m_Objects = {}

    local weak = {}
    weak.__mode = "k"
    setmetatable(layer.m_Wrappers, weak)

    return layer
end

function InteropLayer:Setup()
    local dhtml = self.m_App.m_DHTML

    dhtml:RunJavascript(__glectron_js_library__)

    dhtml:AddFunction("__glectron", "call", function(id, ...)
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
end

function InteropLayer:AddFunction(path, func)
    self.m_App.m_DHTML:RunJavascript("_G_Register(\"" .. path:JavascriptSafe() .. "\"," .. Glectron.Interop:ToInteropObject(self, func) .. ")")
end

function InteropLayer:__call_js(func, ...)
    self.m_App.m_DHTML:RunJavascript(Glectron.Interop:BuildJavascriptCallSignature(self, "_G_Call", func, ...))
end


Glectron.InteropLayer = InteropLayer