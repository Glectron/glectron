type HitTestCallback = (w: number, h: number, x: number, y: number) => boolean | undefined;

const hitTesters: HitTestCallback[] = [];

/**
 * Registers a hit test callback.
 * 
 * Return `true` to notify Glectron a positive hit testing.
 * @param callback - Callback function.
 */
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

/**
 * Sets the enabling state of mouse input.
 * @param enabled Should be mouse input enabled.
 */
export function setMouseInputEnabled(enabled: boolean) {
    window._glectron_lua_.mouseInput(enabled);
}

/**
 * Sets the enabling state of keyboard input.
 * @param enabled Should be keyboard input enabled.
 */
export function setKeyboardInputEnabled(enabled: boolean) {
    window._glectron_lua_.keyboardInput(enabled);
}

/**
 * Makes a popup, enables mouse and keyboard input.
 */
export function makePopup() {
    window._glectron_lua_.makePopup();
}

/**
 * Undo the popup, make application nologer accepts mouse and keyboard input.
 */
export function unPopup() {
    window._glectron_lua_.unPopup();
}

/**
 * Sets the enabling state of global mouse move capture enabled.
 * @param enabled Should global mouse move capture enabled.
 */
export function globalMouseMove(enabled: boolean) {
    window._glectron_lua_.globalMouseMove(enabled);
}

/**
 * Sets the enabling state of global mouse down/up capture enabled.
 * @param enabled Should global mouse down/up capture enabled.
 */
export function mouseCapture(enabled: boolean) {
    window._glectron_lua_.mouseCapture(enabled);
}