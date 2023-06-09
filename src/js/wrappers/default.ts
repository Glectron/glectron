import { Wrapper, addWrapper } from "../interop";

class DefaultWrapper implements Wrapper {
    from(obj: unknown): object {
        return obj as object;
    }
    to(obj: unknown): unknown {
        return obj;
    }
}

addWrapper(new DefaultWrapper, 200);