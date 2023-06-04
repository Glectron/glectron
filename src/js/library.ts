import * as events from "./events";
import { registerLuaFunction, call, collect } from "./interop";

declare global {
    interface Window {
        _glectron_js_: typeof luaBridge;
        _glectron_lua_: {
            call: (id: string, ...args: unknown[]) => void,
            collect: (id: string) => void
        }
        glectron: typeof lib;
    }
}

export const luaBridge = {
    ...events,
    registerLuaFunction,
    call,
    collect,
    setup: function() {
        events.fireEvent("setup");
    }
};
export const lib = {
    get isChromium() {
        return (window as {_GLECTRON_CHROMIUM_?: boolean})._GLECTRON_CHROMIUM_ === true;
    },
    debug: undefined
};