local InteropLayer = {}
InteropLayer.__index = InteropLayer

AccessorFunc(InteropLayer, "m_AllowGlobalCall", "AllowGlobalCall", FORCE_BOOL)

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
    dhtml:AddFunction("_GTRON", "Call", function(methodName, parameters)
    
    end)
    dhtml:AddFunction("_GTRON", "CallGlobal", function(methodName, parameters)
        if not self.m_AllowGlobalCall then
            
        end
    end)
    dhtml:AddFunction("_GTRON", "RemoveReference", function(objectName)
        
    end)
end

function InteropLayer:DoTransform(value)

end

function InteropLayer:CallJavaScriptFunction()

end

function InteropLayer:AddFunction(path, callback)

end


Glectron.InteropLayer = InteropLayer