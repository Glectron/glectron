local Application = {}
Application.__index = Application

function Application:Create()
    local app = {}
    setmetatable(app, Application)
    
    app.m_InteropLayer = Glectron.InteropLayer:Create(app)

    app.m_DummyVGUIPanel = vgui.Create("Panel")
    app.m_DummyVGUIPanel:SetSize(1, 1)
    app.m_DummyVGUIPanel:SetPos(0, -1)

    app.m_DHTML = vgui.Create("DHTML")
    app.m_DHTML:SetAllowLua(false)
    app.m_DHTML:SetFocusTopLevel(true)
    app.m_DHTML:Dock(FILL)
    function app.m_DHTML:OnDocumentReady()
        app.m_InteropLayer:Setup()
        self:AddFunction("_glectron_lua_", "shutdown", function()
            app:_Shutdown()
        end)
        self:AddFunction("_glectron_lua_", "hitTest", function(enabled)
            if app.m_MouseInput then
                app.m_DHTML:SetMouseInputEnabled(enabled)
            end
        end)
        self:AddFunction("_glectron_lua_", "mouseInput", function(enabled)
            app:SetMouseInputEnabled(enabled)
        end)
        self:AddFunction("_glectron_lua_", "keyboardInput", function(enabled)
            app:SetKeyBoardInputEnabled(enabled)
        end)
        self:AddFunction("_glectron_lua_", "makePopup", function(enabled)
            app:MakePopup()
        end)
        self:AddFunction("_glectron_lua_", "unPopup", function(enabled)
            app:UnPopup()
        end)
        self:AddFunction("_glectron_lua_", "globalMouseMove", function(enabled)
            app.m_GlobalMouseMove = enabled
        end)
        self:AddFunction("_glectron_lua_", "mouseCapture", function(enabled)
            app:MouseCapture(enabled)
        end)
        
        if type(app.Setup) == "function" then
            app:Setup()
        end
        self:RunJavascript("_glectron_js_.setup()")
    end

    function app.m_DummyVGUIPanel:OnMousePressed(keyCode)
        app.m_InteropLayer:FireEvent("capturemousepress", { detail = keyCode })
    end

    function app.m_DummyVGUIPanel:OnMouseReleased(keyCode)
        app.m_InteropLayer:FireEvent("capturemouserelease", { detail = keyCode })
    end

    app.m_DHTML:MakePopup()
    app.m_DummyVGUIPanel:MakePopup()
    app.m_DHTML:SetMouseInputEnabled(false)
    app.m_DHTML:SetKeyBoardInputEnabled(false)
    app.m_DummyVGUIPanel:SetMouseInputEnabled(false)
    app.m_DummyVGUIPanel:SetKeyBoardInputEnabled(false)

    table.insert(Glectron.Applications, app)

    return app
end

function Application:SetURL(url)
    self.m_AppURL = url
    self.m_DHTML:OpenURL(url)
end

function Application:SetHTML(html)
    self.m_AppURL = nil
    self.m_DHTML:SetHTML(html)
end

function Application:Reload()
    self.m_DHTML:RunJavascript("location.reload()")
end

function Application:AddFunction(...)
    self.m_InteropLayer:AddFunction(...)
end

function Application:SetMouseInputEnabled(enabled)
    self.m_MouseInput = enabled
    if enabled then
        self:MouseMove(gui.MouseX(), gui.MouseY())
    else
        self.m_DHTML:SetMouseInputEnabled(false)
    end
    self.m_DummyVGUIPanel:SetMouseInputEnabled(enabled)
end

function Application:SetKeyBoardInputEnabled(enabled)
    self.m_DHTML:SetKeyBoardInputEnabled(enabled)
    self.m_DummyVGUIPanel:SetKeyBoardInputEnabled(enabled)
end

function Application:MakePopup()
    local enabled = self.m_DHTML:IsMouseInputEnabled()
    self.m_DummyVGUIPanel:MakePopup()
    self.m_DHTML:MakePopup()
    self.m_DHTML:SetMouseInputEnabled(enabled)
    self:SetMouseInputEnabled(true)
    self.m_InteropLayer:FireEvent("popup")
end

function Application:UnPopup()
    self:SetMouseInputEnabled(false)
    self:SetKeyBoardInputEnabled(false)
    self.m_InteropLayer:FireEvent("unpopup")
end

function Application:MouseCapture(enabled)
    self.m_DummyVGUIPanel:MouseCapture(enabled)
end

function Application:MouseMove(x, y)
    if self.m_MouseInput then
        self.m_InteropLayer:RunJavascriptFunction("_glectron_js_.hitTest", ScrW(), ScrH(), x, y)
    end
    if self.m_GlobalMouseMove then
        self.m_InteropLayer:FireEvent("globalmousemove", { detail = {x = x, y = y} })
    end
end

function Application:_Shutdown()
    self.m_DummyVGUIPanel:Remove()
    self.m_DHTML:Remove()
    table.RemoveByValue(Glectron.Applications, self)
end
Application.ForceShutdown = Application._Shutdown

function Application:Shutdown()
    self.m_InteropLayer:RunJavascriptFunction("_glectron_js_.shutdown")
end

Glectron.Application = Application