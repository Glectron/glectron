export const persistedAreas: Map<Storage, boolean> = new Map();

let loadResolve: (value?: unknown) => void;
export const storagePromise = new Promise((resolve) => {
    loadResolve = resolve;
});

localStorage.clear();

Storage.prototype.persist = function(shouldPersist) {
    if (this != localStorage) {
        throw "Storage besides localStorage isn't supported now.";
    }
    if (shouldPersist) {
        persistedAreas.set(this, true);
    } else {
        persistedAreas.delete(this);
    }
};

const originalSetItem = Storage.prototype.setItem;
Storage.prototype.setItem = function(key, value) {
    originalSetItem.bind(this, key, value)();
    if (!persistedAreas.has(this)) return;
    window._glectron_lua_.setStorage(key, value);
};

const originalRemoveItem = Storage.prototype.removeItem;
Storage.prototype.removeItem = function(key) {
    originalRemoveItem.bind(this, key)();
    if (!persistedAreas.has(this)) return;
    window._glectron_lua_.setStorage(key);
};

const originalClear = Storage.prototype.clear;
Storage.prototype.clear = function() {
    originalClear.bind(this)();
    if (!persistedAreas.has(this)) return;
    window._glectron_lua_.clearStorage();
};

localStorage.persist(true);

addEventListener("setup", () => {
    window._glectron_lua_.getStorage((storage) => {
        if (storage)
            for (const pair of storage) {
                originalSetItem.bind(localStorage, pair.key, pair.value)();
            }
        loadResolve();
    });
});