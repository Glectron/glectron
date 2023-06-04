import "./polyfill";
import { fireEvent } from "./events";
import { luaBridge, lib } from "./library";

import "./wrappers";
import { objectObjs, wrapperObjs } from "./interop";

window._glectron_js_ = luaBridge;
window.glectron = lib;

fireEvent("glectronlibloaded");

declare const glectron: {debug?: {__initialize: (...debugArgs: unknown[]) => void}};

if (glectron?.debug) {
    glectron.debug.__initialize(wrapperObjs, objectObjs);
    window.glectron.debug = glectron.debug;
}