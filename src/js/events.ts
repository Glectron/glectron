export function fireEvent(name: string, data?: object) {
    window.dispatchEvent(new CustomEvent(name, data));
}