import { fireEvent } from "./events";
import { luaBridge, lib } from "./library";

window._glectron_js_ = luaBridge;
window.glectron = lib;

fireEvent("glectronjsloaded");