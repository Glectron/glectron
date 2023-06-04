const interop = {
    wrappers: null,
    objects: null
};

function initialize(...args: unknown[]) {
    interop.wrappers = args[0];
    interop.objects = args[1];
    document.title = "_GLECTRON_APP_";
    console.log("Glectron library is running in debug mode.");
}

export default {
    interop,
    __initialize: initialize
};