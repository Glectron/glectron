import { lib } from "./library";

export type GlectronAPI = typeof lib;

declare global {
    const glectron: GlectronAPI;
    interface Window {
        glectron: GlectronAPI
    }
    interface Storage {
        /**
         * Sets persistence of the `Storage` object.
         * 
         * Only `localStorage` is supported.
         * @param shouldPersist Indicates this storage should be persisted or not
         */
        persist(shouldPersist: boolean): void
    }
    interface WindowEventMap {
        "glectronlibloaded": Event,
        "setup": Event,
        "popup": Event,
        "unpopup": Event,
        "globalmousemove": CustomEvent<{
            x: number,
            y: number
        }>,
        "capturemousepress": CustomEvent<number>,
        "capturemouserelease": CustomEvent<number>
    }
}