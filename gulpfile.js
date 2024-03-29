const rollup = require("rollup");
const gulp = require("gulp");
const replace = require("gulp-replace");
const rename = require("gulp-rename");
const inject = require("@rollup/plugin-inject");
const babel = require("@rollup/plugin-babel");
const typescript = require("@rollup/plugin-typescript");
const terser = require("@rollup/plugin-terser");
const commonjs = require("@rollup/plugin-commonjs");
const nodeResolve = require("@rollup/plugin-node-resolve");

const fs = require("fs");
const path = require("path");

function btoaUTF8(string, bomit) {
    return btoa((bomit ? "\xEF\xBB\xBF" : "") + string.replace(/[\x80-\uD7ff\uDC00-\uFFFF]|[\uD800-\uDBFF][\uDC00-\uDFFF]?/g, function(nonAsciiChars) {
        const fromCharCode = String.fromCharCode;
        let point = nonAsciiChars.charCodeAt(0);
        if (point >= 0xD800 && point <= 0xDBFF) {
            var nextcode = nonAsciiChars.charCodeAt(1);
            if (nextcode !== nextcode) // NaN because string is 1 code point long
                return fromCharCode(0xef/*11101111*/, 0xbf/*10111111*/, 0xbd/*10111101*/);
            // https://mathiasbynens.be/notes/javascript-encoding#surrogate-formulae
            if (nextcode >= 0xDC00 && nextcode <= 0xDFFF) {
                point = (point - 0xD800) * 0x400 + nextcode - 0xDC00 + 0x10000;
                if (point > 0xffff)
                    return fromCharCode(
                        (0x1e/*0b11110*/<<3) | (point>>>18),
                        (0x2/*0b10*/<<6) | ((point>>>12)&0x3f/*0b00111111*/),
                        (0x2/*0b10*/<<6) | ((point>>>6)&0x3f/*0b00111111*/),
                        (0x2/*0b10*/<<6) | (point&0x3f/*0b00111111*/)
                    );
            } else return fromCharCode(0xef, 0xbf, 0xbd);
        }

        if (point <= 0x007f) return nonAsciiChars;
        else if (point <= 0x07ff) {
            return fromCharCode((0x6<<5)|(point>>>6), (0x2<<6)|(point&0x3f));
        } else return fromCharCode(
            (0xe/*0b1110*/<<4) | (point>>>12),
            (0x2/*0b10*/<<6) | ((point>>>6)&0x3f/*0b00111111*/),
            (0x2/*0b10*/<<6) | (point&0x3f/*0b00111111*/)
        );
    }));
}

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

    if (production)
        plugins.push(terser());
    else
        plugins.unshift(inject({
            "glectron.debug": path.resolve("src/js/debug.ts")
        }));

    const bundle = await rollup.rollup({
        input: "src/js/index.ts",
        plugins
    });
    return await bundle.write({
        file: "build/js/library.js",
        format: "iife",
        name: "library",
        sourcemap: production ? false : "inline"
    });
}

function lua() {
    const library = fs.readFileSync("build/js/library.js", {encoding: "utf-8"});

    return gulp.src("src/lua/**/*.lua", {base: "src/"})
        .pipe(replace("%GLECTRON_JS_LIBRARY%", btoaUTF8(library)))
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