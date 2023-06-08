import { fireEvent } from "./events";

type BeforeShutdownCallback = () => Promise<boolean | undefined>;
type ShutdownCallback = () => Promise<void>;

const beforeShutdownCallbacks: BeforeShutdownCallback[] = [];
const shutdownCallbacks: ShutdownCallback[] = [];

export function beforeShutdown(callback: BeforeShutdownCallback) {
    beforeShutdownCallbacks.push(callback);
}

export function onShutdown(callback: ShutdownCallback) {
    shutdownCallbacks.push(callback);
}

export function setup() {
    fireEvent("setup");
}

export async function shutdown() {
    for (const callback of beforeShutdownCallbacks) {
        const ret = await callback();
        if (ret === true) return; // Shutdown cancelled
    }
    // Shutdown confirmed
    for (const callback of shutdownCallbacks) {
        await callback();
    }
    window._glectron_lua_.shutdown();
}