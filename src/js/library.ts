import * as events from "./events";
import { registerLuaFunction, call, collect } from "./interop";
import { beforeShutdown, onShutdown, setup, shutdown } from "./lifecycle";
import { hitTest, onHitTest, setMouseInputEnabled, setKeyboardInputEnabled, makePopup, unPopup } from "./input";

declare global {
    interface Window {
        _glectron_js_: typeof luaBridge;
        _glectron_lua_: {
            call: (id: string, ...args: unknown[]) => void,
            collect: (id: string) => void,
            shutdown: () => void,
            hitTest: (enabled: boolean) => void
            mouseInput: (enabled: boolean) => void,
            keyboardInput: (enabled: boolean) => void,
            makePopup: () => void,
            unPopup: () => void
        }
        glectron: typeof lib;
    }
}

export const luaBridge = {
    ...events,
    registerLuaFunction,
    call,
    collect,
    setup,
    shutdown,
    hitTest,
    fireEvent: events.fireEvent
};
export const lib = {
    get isChromium() {
        return (window as {_GLECTRON_CHROMIUM_?: boolean})._GLECTRON_CHROMIUM_ === true;
    },
    beforeShutdown,
    onShutdown,
    onHitTest,
    setMouseInputEnabled,
    setKeyboardInputEnabled,
    makePopup,
    unPopup,
    debug: undefined
};