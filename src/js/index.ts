import "./polyfill";
import { fireEvent } from "./events";
import { luaBridge, lib } from "./library";

import "./wrappers";

window._glectron_js_ = luaBridge;
window.glectron = lib;

fireEvent("glectronlibloaded");