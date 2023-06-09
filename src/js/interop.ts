const wrappers: [Wrapper, number][] = [];

export const wrapperObjs: Map<object, string> | WeakMap<object, string> = "WeakMap" in window ? new WeakMap() : new Map();
export const objectObjs: Map<string, InteropObject> = new Map();

export type InteropObject = object | string | number | boolean;

export interface Wrapper {
    from(obj: unknown): InteropObject | undefined;
    to(obj: unknown): unknown | undefined;
}

export function fromInteropObject(obj: unknown): InteropObject {
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
            return (window as {_GLECTRON_CHROMIUM_?: boolean})._GLECTRON_CHROMIUM_ === true ? ret : (typeof ret == "object" ? "!GOBJ!" + JSON.stringify(ret) : ret);
        }
    }
    return null;
}

export function isInteropObject(obj: unknown): boolean {
    if (typeof obj !== "object") return false;
    return (obj as { _G_InteropObj?: boolean })._G_InteropObj === true;
}

export function interopObjectType(obj: unknown): string | null {
    if (typeof obj == "object") {
        const o = obj as { _G_InteropObj?: boolean, _G_InteropType?: string };
        if (o && o._G_InteropObj) {
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

export function collect(id: string) {
    objectObjs.delete(id);
}

function sortWrappers() {
    wrappers.sort((a, b) => a[1] - b[1]);
}

export function addWrapper(wrapper: Wrapper, priority = 0) {
    wrappers.push([wrapper, priority]);
    sortWrappers();
}