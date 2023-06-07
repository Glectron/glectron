const interop = {
    wrappers: null,
    objects: null
};

function initialize(...args: unknown[]) {
    interop.wrappers = args[0];
    interop.objects = args[1];
    document.title = (document.title == "" ? location.href : document.title) + "\u2061";
    const observer = new ("MutationObserver" in window ? MutationObserver : window["WebKitMutationObserver"])((mutation) => {
        const newVal = mutation[0].target.nodeValue;
        if (newVal.indexOf("\u2061") != -1) return;
        document.title = newVal + "\u2061";
    });
    observer.observe(document.querySelector("title"), {
        subtree: true,
        characterData: true,
        childList: true
    });
    console.log("Glectron library is running in debug mode.");
}

export default {
    interop,
    __initialize: initialize
};