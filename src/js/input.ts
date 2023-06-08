type HitTestCallback = (w: number, h: number, x: number, y: number) => boolean;

const hitTesters: HitTestCallback[] = [];

export function onHitTest(callback: HitTestCallback) {
    hitTesters.push(callback);
}

export function hitTest(w: number, h: number, x: number, y: number) {
    for (const hitTester of hitTesters) {
        const ret = hitTester(w, h, x, y);
        if (ret === true) {
            window._glectron_lua_.hitTest(true);
            return;
        }
    }
    window._glectron_lua_.hitTest(false);
}

export function setMouseInputEnabled(enabled: boolean) {
    window._glectron_lua_.mouseInput(enabled);
}

export function setKeyboardInputEnabled(enabled: boolean) {
    window._glectron_lua_.keyboardInput(enabled);
}

export function makePopup() {
    window._glectron_lua_.makePopup();
}

export function unPopup() {
    window._glectron_lua_.unPopup();
}