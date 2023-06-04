const rollup = require("rollup");
const gulp = require("gulp");
const replace = require("gulp-replace");
const rename = require("gulp-rename");
const babel = require("@rollup/plugin-babel");
const typescript = require("@rollup/plugin-typescript");
const terser = require("@rollup/plugin-terser");
const commonjs = require("@rollup/plugin-commonjs");
const nodeResolve = require("@rollup/plugin-node-resolve");

const fs = require("fs");

const production = process.env.NODE_ENV?.trim() == "production";
const version = {
    major: 0,
    minor: 0,
    patch: 1
};

try {
    const pkg = JSON.parse(fs.readFileSync("package.json", {encoding: "utf-8"}));
    const version = pkg.version;
    const parts = version.split(".");
    version.major = parseInt(parts[0]) || 0;
    version.minor = parseInt(parts[1]) || 0;
    version.patch = parseInt(parts[2]) || 1;
} catch {
    console.warn("Unable to read package version.");
}

async function javascript() {
    const plugins = [
        typescript(),
        commonjs({
            sourceMap: false
        }),
        nodeResolve(),
        babel({ babelHelpers: "bundled", extensions: [".js", ".ts"] })
    ];

    if (production) plugins.push(terser());

    const bundle = await rollup.rollup({
        input: "src/js/index.ts",
        plugins
    });
    return await bundle.write({
        file: "build/js/library.js",
        format: "iife",
        name: "library",
        sourcemap: !production
    });
}

function lua() {
    const library = fs.readFileSync("build/js/library.js", {encoding: "utf-8"});

    return gulp.src("src/lua/**/*.lua", {base: "src/"})
        .pipe(replace("%GLECTRON_JS_LIBRARY%", library))
        .pipe(replace("%GLECTRON_PATH%", process.env.GLECTRON_PATH?.trim() || "glectron"))
        .pipe(replace("\"%GLECTRON_VER_MAJOR%\"", version.major))
        .pipe(replace("\"%GLECTRON_VER_MINOR%\"", version.minor))
        .pipe(replace("\"%GLECTRON_VER_PATCH%\"", version.patch))
        .pipe(rename(function(path) {
            if (process.env.GLECTRON_ID) {
                if (path.dirname == "lua\\autorun" && path.basename == "glectron") {
                    path.basename = process.env.GLECTRON_ID.trim();
                }
            }
            if (process.env.GLECTRON_PATH) {
                if (path.dirname.startsWith("lua\\glectron")) {
                    path.dirname = "lua\\" + process.env.GLECTRON_PATH.trim() + path.dirname.substring(12);
                }
            }
        }))
        .pipe(gulp.dest("build/glectron"));
}

const build = gulp.series(javascript, lua);

function watch() {
    gulp.watch("src/js", build);
    gulp.watch("src/lua", lua);
}

exports.watch = watch;
exports.default = build;