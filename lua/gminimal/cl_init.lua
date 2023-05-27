local __glectron_js_library__ = [[
    !function() {
        const js_func = {};
        const lua_func = {};
        const app_setup_evnt = new Event("setup");

        function toInteropObject(obj) {
            if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean" || typeof obj == "object") {
                return obj;
            } else if (typeof obj == "function") {
                if (lua_func[obj]) {
                    let id = lua_func[obj];
                    return {
                        _G_InteropObj: true,
                        _G_InteropType: "luafunction",
                        _G_FuncID: id
                    };
                } else {
                    let id = obj.toString(); // this is too simple
                    js_func[id] = obj;
                    return {
                        _G_InteropObj: true,
                        _G_InteropType: "jsfunction",
                        _G_FuncID: id
                    }
                }
            } else {
                // ummm...
            }
        }

        function fromInteropObject(obj) {
            if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean") {
                return obj;
            } else if (typeof obj == "object") {
                if (obj._G_InteropObj) {
                    switch (obj._G_InteropType) {
                        case "luafunction":
                            let id = obj._G_FuncID;
                            let func = function() {
                                const parameters = [];
                                for (let i = 0;i<arguments.length;i++) {
                                    parameters.push(toInteropObject(arguments[i]));
                                }
                                glectron.call(id,...parameters);
                            }
                            return func;
                        case "jsfunction":
                            return js_func[obj._G_FuncID];
                    }
                } else {
                    return obj;
                }
            }
        }

        function onAppSetup() {
            window.dispatchEvent(app_setup_evnt);
        }
        function call() {
            const id = arguments[0];
            const parameters = [];
            for (let i = 1;i < arguments.length;i++) {
                parameters.push(fromInteropObject(arguments[i]));
            }
            js_func[id](...parameters);
        }
        function register(path, func) {
            const fn = fromInteropObject(func);
            window[path] = fn;
        }

        window._G_OnAppSetup = onAppSetup;
        window._G_Call = call;
        window._G_Register = register;
    }();
]]

function toInteropObject(app, obj)
    if type(obj) == "string" then
        return "\"" .. obj:JavascriptSafe() .. "\""
    elseif type(obj) == "number" or type(obj) == "bool" then
        return tostring(obj)
    elseif type(obj) == "table" then
        return util.TableToJSON(obj)
    elseif type(obj) == "function" then
        if app.__js_func__[obj] then
            local id = app.__js_func__[obj]
            return util.TableToJSON({
                _G_InteropObj = true,
                _G_InteropType = "jsfunction",
                _G_FuncID = id
            })
        else
            local strid = util.Base64Encode(tostring(obj), true)
            app.__lua_func__[strid] = obj
            return util.TableToJSON({
                _G_InteropObj = true,
                _G_InteropType = "luafunction",
                _G_FuncID = strid
            })
        end
    else
        -- TODO: a more common interop type exchanging
    end
end

function fromInteropObject(app, obj)
    if type(obj) == "string" or type(obj) == "number" or type(obj) == "bool" then
        return obj
    elseif type(obj) == "table" then
        if obj._G_InteropObj then
            if obj._G_InteropType == "luafunction" then
                -- this means we are taking back an interoped lua function
                return app.__lua_func__[obj._G_FuncID]
            elseif obj._G_InteropType == "jsfunction" then
                local func = function(...)
                    app:__call_js(obj._G_FuncID, ...)
                end
                app.__js_func__[func] = obj._G_FuncID
                return func
            else
                -- TODO: not implemented
            end
        else
            return obj
        end
    end
end

function makeInterop(app)
    app.__lua_func__ = {}
    app.__js_func__ = {}
    app.__dhtml__:AddFunction("glectron", "call", function(id, ...)
        local func = app.__lua_func__[id]
        if not func then
            error("invalid func id")
        end
        local parameters = {...}
        local p = {}
        for _,v in ipairs(parameters) do
            table.insert(p, fromInteropObject(app, v))
        end
        func(unpack(p))
    end)
    app.__call_js = function(app, id, ...)
        local parameters = {...}
        local p = ""
        for _,v in ipairs(parameters) do
            p = p .. toInteropObject(app, v) .. ","
        end
        p = string.sub(p, 1, #p - 1)
        app.__dhtml__:RunJavascript("_G_Call(\"" .. id:JavascriptSafe() .. "\"," .. p .. ")")
    end
    app.RegisterLuaFunction = function(app, path, func)
        app.__dhtml__:RunJavascript("_G_Register(\"" .. path:JavascriptSafe() .. "\"," .. toInteropObject(app, func) .. ")")
    end
end

hook.Add("InitPostEntity", "Glectron", function()
    local apps = {}

    for _, v in pairs(file.Find("gapp/*.lua", "LUA")) do
        APP = {}
        include("gapp/" .. v)
        if not APP.__html_source__ then
            print(v, "is not a valid Glectron app.")
        end
        APP.__dhtml__ = vgui.Create("DHTML")
        APP.__dhtml__:ParentToHUD()
        APP.__dhtml__:Dock(FILL)
        APP.__dhtml__:SetHTML("<script>" .. __glectron_js_library__ .. "</script>" .. APP.__html_source__)
        local app = APP
        function APP.__dhtml__:OnDocumentReady()
            app:Setup()
            app.__dhtml__:RunJavascript("_G_OnAppSetup()")
        end
        makeInterop(APP)
        table.insert(apps, APP)
    end
    APP = nil

end)