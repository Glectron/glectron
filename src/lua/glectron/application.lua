local Application = {}
Application.__index = Application

function Application:Create()
    local app = {}
    setmetatable(app, Application)
    
    app.m_InteropLayer = Glectron.InteropLayer:Create(app)

    app.m_DHTML = vgui.Create("DHTML")
    app.m_DHTML:ParentToHUD()
    function app.m_DHTML:OnDocumentReady()
        app.m_InteropLayer:Setup()
        if type(app.Setup) == "function" then
            app:Setup()
        end
        self:RunJavascript("_G_OnAppSetup()")
    end

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

Glectron.Application = Application