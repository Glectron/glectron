import { InteropObject, Wrapper, addWrapper } from "../interop";

class PrimitiveWrapper implements Wrapper {
    from(obj: unknown): InteropObject {
        if (obj === null || obj === undefined) return null;
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean") {
            return obj;
        }
    }
    to(obj: unknown): unknown {
        if (obj === null || obj === undefined) return null;
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean" || typeof obj == "object") {
            return obj;
        }
    }
}

addWrapper(new PrimitiveWrapper, -10);