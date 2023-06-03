const finalRegistry = "FinalizationRegistry" in window ? new FinalizationRegistry((id: string) => {
    window._glectron_lua_.collect(id);
}) : undefined;

export function registerInteropObjectGC(obj: object, id: string) {
    if (finalRegistry === undefined) return;
    finalRegistry.register(obj, id);
}