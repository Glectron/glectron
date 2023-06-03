<p align="center"><img src="assets/glectron.svg" alt="Glectron"></p>
<p align="center">Electron in Garry's Mod.</p>

# Work In Progress
The project is still in Early State of development. You can check out all technical concepts in [Discussions](https://github.com/Glectron/glectron/discussions).

# Project Structure
<pre>
├── assets <i>(Project assets)</i>
├── src <i>(Source code)</i>
│   ├── js <i>(JavaScript library source code)</i>
│   │   ├── **/*.ts
│   ├── lua <i>(Lua source code)</i>
│   │   ├── **/*.lua
├── build <i>(Builds, ignored by Git)</i>
├── node_modules <i>(Node modules, ignored by Git)</i>
├── package.json <i>(Node package file)</i>
├── yarn.lock <i>(Yarn lockfile)</i>
├── gulpfile.js <i>(Gulp workflow)</i>
├── babel.config.json <i>(Babel configuration)</i>
├── .eslintrc.json <i>(ESLint configuration)</i>
└── .gitignore <i>(Git ignore filelist)</i>
</pre>

# Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md)