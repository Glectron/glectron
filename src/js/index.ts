import "./polyfill";
import { fireEvent } from "./events";
import { luaBridge, lib } from "./library";

import "./wrappers";
import { objectObjs, wrapperObjs } from "./interop";
import { storagePromise } from "./storage";

window._glectron_js_ = luaBridge;
window.glectron = lib;

const loadPromises = [
    storagePromise
];

Promise.allSettled(loadPromises).then(() => {
    fireEvent("glectronlibloaded");
});

declare const glectron: {debug?: {__initialize: (...debugArgs: unknown[]) => void}};

if (glectron?.debug) {
    glectron.debug.__initialize(wrapperObjs, objectObjs);
    window.glectron.debug = glectron.debug;
}