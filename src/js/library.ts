import * as events from "./events";
import * as interop from "./interop";

declare global {
    interface Window {
        _glectron_js_: typeof luaBridge;
        glectron: typeof lib;
    }
}

export const luaBridge = {
    ...events,
    ...interop
};
export const lib = {

};