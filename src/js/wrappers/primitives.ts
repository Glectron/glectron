import { InteropObject, Wrapper, addWrapper } from "../interop";

class PrimitiveWrapper implements Wrapper {
    from(obj: unknown): InteropObject {
        if (obj == undefined) return null;
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean") {
            return obj;
        }
    }
    to(obj: unknown): unknown {
        if (obj == undefined) return null;
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean") {
            return obj;
        }
    }
}

addWrapper(new PrimitiveWrapper, -10);