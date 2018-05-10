# zar

A simple dice application for web and mobile platforms. Simply visit https://zar.now.sh or https://dice.now.sh and tap on the screen to roll the dices. If you want you can create a desktop shortcut for the Zar for both iOS and Android and you can use it as an application.

## Getting Started

After cloning the repo, cd into `zar` directory and do;

```
  $ npm install
  $ npm start
```

This will open your browser with `localhost:9000` and you should see the `zar` project alive \o/

## Production

By default while developing there is no minify or uglify process happening but for production environments to reduce the file sizes we need to tell builder (gulp) to generate output for production;

```
  $ npm run production
```

This will build everything for production and then run tests. You can use the `./dist` folder to deploy your app, all the required files are in that folder, production ready.

## Tests

You can run tests simply by calling;

```
  $ npm test
```

This will start testing for every `.coffee` files under `./test` directory. Where you can see an example test in `main.spec.coffee`. In the same folder there is another file called `bootstrap.coffee` which is responsible for booting up Puppeteer for tests.

If you want to keep tests running whenever the bundle or a test spec changed;

```
  $ npm run test:watch
```

## License

MIT 2018 Gokmen Goksel
