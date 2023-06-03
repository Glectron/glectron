import * as events from "./events";
import { registerLuaFunction, call } from "./interop";

declare global {
    interface Window {
        _glectron_js_: typeof luaBridge;
        _glectron_lua_: {
            call: (id: string, ...args: unknown[]) => void
        }
        glectron: typeof lib;
    }
}

export const luaBridge = {
    ...events,
    registerLuaFunction,
    call,
    setup: function() {
        events.fireEvent("setup");
    }
};
export const lib = {

};