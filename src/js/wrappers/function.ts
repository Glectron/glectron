import { registerInteropObjectGC } from "../gc";
import { InteropObject, Wrapper, addWrapper, createInteropObject, interopObjectType, objectObjs, toInteropObject, wrapperObjs } from "../interop";
import { random_string } from "../util";

class FunctionWrapper implements Wrapper {
    from(obj: unknown): InteropObject {
        if (typeof obj == "object") {
            const t = interopObjectType(obj);
            if (t == "luafunction") {
                const id = (obj as {ID: string}).ID;
                const func = function(...args: unknown[]) {
                    const parameters = [];
                    for (let i = 0;i<args.length;i++) {
                        parameters.push(toInteropObject(args[i]) as never);
                    }
                    window._glectron_lua_.call(id, ...parameters);
                };
                wrapperObjs.set(func, id);
                registerInteropObjectGC(func, id);
                return func;
            } else if (t == "jsfunction") {
                return objectObjs.get((obj as {ID: string}).ID);
            }
        }
    }
    to(obj: unknown): unknown {
        if (typeof obj == "function") {
            const func = obj as (...args: unknown[]) => void;
            if (wrapperObjs.has(func)) {
                const id = wrapperObjs.get(func);
                return createInteropObject("luafunction", {
                    ID: id
                });
            } else {
                const id = random_string(10);
                objectObjs.set(id, obj);
                return createInteropObject("jsfunction", {
                    ID: id
                });
            }
        }
    }
}

addWrapper(new FunctionWrapper);