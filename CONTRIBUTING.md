# Introduction
We welcome everyone join us and help us to make Glectron possible. Don't be hesitate if you'd like to make some contributions (even just a little!).

This contribution guide is mainly written for developers, but don't be sad if you don't know how to code! We welcome all kinds of contributions, such as bug reporting, feature requesting and improvement suggesting. To do so, you can simply check out [Issues](https://github.com/Glectron/glectron/issues) and [Discussions](https://github.com/orgs/Glectron/discussions).

For developers, just simply follow this guide and you can start work on Glectron!

# Getting Started

## Setting up the environment
### Node.JS
Glectron uses a set of JavaScript scripts to maintain project structure clean and indepent between Lua side and JavaScript side, which means you will need [Node.JS](https://nodejs.org/) to setup the development environment.

To download [Node.JS](https://nodejs.org/), you need to visit the [Node.JS website](https://nodejs.org/), and choose a version to download. There's no much requirements on Node.JS versions, you can just choose `LTS` or `Current` as you like.

### Yarn (optional)
By default, Node.JS uses `npm` as default package manager. Glectron uses `yarn`. It will be better if you install Yarn.

To install Yarn, open up a command prompt window and type in `npm install -g yarn`, then NPM will install Yarn as a global package.

## Setting up the project
Before start your work, you need to install the dependencies first, they are required for development toolset to work.

It's quite simple, run the following command inside your command prompt.
```bash
# Yarn
yarn install

# NPM
npm install
```
The package managers will do all the work for you.

## Developing
Now you can write some code for Glectron! To test it in your game, you need to build Glectron before putting it inside you `addons` folder.

To build Glectron, use the following command.
```bash
# Yarn
yarn build:dev

# NPM
npm run build:dev
```

If you want to build automatically every time you change the source code, run the following command.
```bash
# Yarn
yarn watch:dev

# NPM
npm run watch:dev
```

After build is completed, copy `build/glectron` folder into your `addons` folder.

## Production Build
Production builds provide smaller bundled JavaScript library. To build Glectron in production mode, use the following command.
```bash
# Yarn
yarn build

# NPM
npm run build
```

`watch` command also supports production mode, for example:
```bash
# Yarn
yarn watch

# NPM
npm run watch
```