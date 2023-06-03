import { Wrapper, addWrapper, interopObjectType } from "../interop";

class ObjectWrapper implements Wrapper {
    from(obj: unknown): unknown {
        if (typeof obj === "object") {
            if (interopObjectType(obj) == null) {
                return obj;
            }
        }
    }
    to(obj: unknown): unknown {
        if (typeof obj === "object") {
            return obj;
        }
    }
}

addWrapper(new ObjectWrapper, 100);