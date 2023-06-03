const rollup = require("rollup");
const gulp = require("gulp");
const replace = require("gulp-replace");
const rename = require("gulp-rename");
const babel = require("@rollup/plugin-babel");
const typescript = require("@rollup/plugin-typescript");
const terser = require("@rollup/plugin-terser");

const fs = require("fs");

const production = process.env.NODE_ENV?.trim() == "production";

async function javascript() {
    const plugins = [
        typescript(),
        babel({ babelHelpers: "bundled" })
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