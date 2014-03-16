# Webflix

A lightweight web app wrapper for [peerflix](https://github.com/mafintosh/peerflix).
I'm sure someone else already has done this.

![index](https://raw.github.com/JoelBesada/webflix/master/screenshots/index.png)
![stream](https://raw.github.com/JoelBesada/webflix/master/screenshots/stream.png)

## Installation
```
git clone git@github.com:JoelBesada/webflix.git
cd webflix
npm install
npm install -g coffee-script
```

## Usage
Run `app/app.coffee` to start the server.

```
coffee app/app.coffee
```

The app accepts the following command-line options:

```
--user <username> A username to be used in HTTP basic auth, has to be combined with --password
--password <password> A password to be used in HTTP basic auth, has to be combined with --use
--port <port> The port the web app will run on. Note that the stream will always be on port 8888.
```

Depending on the format of the stream, you can either view it directly in your web browser
or from a media player like VLC.

## License
MIT License, see the LICENSE file.