import { lib } from "./library";

export type GlectronAPI = typeof lib;

declare global {
    const glectron: GlectronAPI;
    interface Window {
        glectron: GlectronAPI
    }
}