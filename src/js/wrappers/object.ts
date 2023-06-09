import { Wrapper, addWrapper, fromInteropObject, isInteropObject, toInteropObject } from "../interop";

class ObjectWrapper implements Wrapper {
    from(obj: unknown): object {
        if (typeof obj === "object" && !isInteropObject(obj)) {
            const newObj = Array.isArray(obj) ? [] : {};
            for (const k in obj) {
                const v = obj[k];
                newObj[k] = fromInteropObject(v);
            }
            return newObj;
        }
    }
    to(obj: unknown): unknown {
        if (typeof obj === "object" && !isInteropObject(obj)) {
            const newObj = Array.isArray(obj) ? [] : {};
            for (const k in obj) {
                const v = obj[k];
                newObj[k] = isInteropObject(v) ? v : toInteropObject(v);
            }
            return newObj;
        }
    }
}

addWrapper(new ObjectWrapper, 100);