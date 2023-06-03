// TODO: Migrate into current JavaScript library framework
// temporary library
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
                    ID: id
                };
            } else {
                let id = obj.toString(); // this is too simple
                js_func[id] = obj;
                return {
                    _G_InteropObj: true,
                    _G_InteropType: "jsfunction",
                    ID: id
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
                        let id = obj.ID;
                        let func = function() {
                            const parameters = [];
                            for (let i = 0;i<arguments.length;i++) {
                                parameters.push(toInteropObject(arguments[i]));
                            }
                            __glectron.call(id,...parameters);
                        }
                        return func;
                    case "jsfunction":
                        return js_func[obj.ID];
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