import { Wrapper, addWrapper } from "../interop";

class PrimitiveWrapper implements Wrapper {
    from(obj: unknown): unknown {
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean") {
            return obj;
        }
    }
    to(obj: unknown): unknown {
        if (typeof obj == "string" || typeof obj == "number" || typeof obj == "boolean" || typeof obj == "object") {
            return obj;
        }
    }
}

addWrapper(new PrimitiveWrapper, -10);