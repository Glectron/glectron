const wrappers: [Wrapper, number][] = [];

export const wrapperObjs: Map<unknown, string> = new Map();
export const objectObjs: Map<string, unknown> = new Map();

export interface Wrapper {
    from(obj: unknown): unknown | undefined;
    to(obj: unknown): unknown | undefined;
}

export function fromInteropObject(obj: unknown): unknown {
    for (const wrapper of wrappers) {
        const ret = wrapper[0].from(obj);
        if (ret !== undefined) {
            return ret;
        }
    }
    return null;
}

export function toInteropObject(obj: unknown): unknown {
    for (const wrapper of wrappers) {
        const ret = wrapper[0].to(obj);
        if (ret !== undefined) {
            return ret;
        }
    }
    return null;
}

export function interopObjectType(obj: unknown): string | null {
    if (typeof obj == "object") {
        const o = obj as { _G_InteropObj?: boolean, _G_InteropType?: string };
        if (o._G_InteropObj) {
            return o._G_InteropType as string;
        }
    }
    return null;
}

export function createInteropObject(type: string, data: object = {}): object {
    return {
        _G_InteropObj: true,
        _G_InteropType: type,
        ...data
    };
}

export function registerLuaFunction(path: string, func: unknown) {
    const a = path.split(".");
    let o = window;
    while (a.length - 1) {
        const n = a.shift() as string;
        if (!(n in o)) o[n] = {};
        o = o[n];
    }
    o[a[0]] = fromInteropObject(func);
}

export function call(id: string, ...args: unknown[]) {
    if (!objectObjs.has(id)) {
        throw Error("undefined function " + id);
    }

    const parameters: unknown[] = [];
    for (const arg of args) {
        parameters.push(fromInteropObject(arg));
    }

    const func = objectObjs.get(id) as (...args: unknown[]) => void;
    func(...parameters);
}

function sortWrappers() {
    wrappers.sort((a, b) => a[1] - b[1]);
}

export function addWrapper(wrapper: Wrapper, priority = 0) {
    wrappers.push([wrapper, priority]);
    sortWrappers();
}