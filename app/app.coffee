peerflix = require "peerflix"
express = require "express"
consolidate = require "consolidate"
networkAddress = require "network-address"

argv = require("minimist") process.argv.slice(2)

class App
  isStreaming: false
  streamData: null

  streamEngine: null
  expressApp: null

  routes:
    "GET /": "getIndex"
    "GET /stream": "getStream"
    "POST /stream": "postStream"
    "POST /stream/stop": "stopStream"

  constructor: ->
    @setup()

  setup: ->
    @expressApp = express()
    if argv.user and argv.password
      @expressApp.use express.basicAuth(argv.user, argv.password)

    @expressApp.use express.static("#{__dirname}/static")
    @expressApp.set "views", "#{__dirname}/views"
    @expressApp.set "view engine", "hbs"
    @expressApp.engine "hbs", consolidate.handlebars

    @expressApp.use express.bodyParser()

    @setupRoutes()

    port = argv.port or 8887
    @expressApp.listen port
    console.log "App listening on port #{port}"

  setupRoutes: ->
    for route, handler of @routes
      [method, path] = route.split " "
      @expressApp[method.toLowerCase()](path, @[handler].bind(this))

  startStream: (torrent, cb) ->
    port = argv.streamport or 8888
    console.log "Starting stream from #{torrent}"
    peerflix torrent, (err, engine) =>
      @streamEngine = engine
      unless @streamEngine?.server
        console.log "Failed to start stream"
        return cb(new Error("Failed to start stream"))

      @streamEngine.server.once "listening", =>
        console.log "Stream started successfully"
        @isStreaming = true
        @streamData =
          href: "http://#{networkAddress()}:#{[port]}"
          torrent: @streamEngine.torrent.name

        cb()

      @streamEngine.server.listen argv.streamport or 8888

  destroyStream: (cb) ->
    console.log "Destroying current stream of #{@streamData?.torrent}"

    @streamEngine?.destroy(cb)
    @streamEngine = null
    @isStreaming = null
    @streamData = null

  ###
  # Route Handlers
  ###

  getIndex: (req, res) ->
    res.render "index", {
      isStreaming: @isStreaming
      streamData: @streamData
    }

  getStream: (req, res) ->
    return res.send("No stream available") unless @streamData?.href
    res.redirect @streamData.href

  postStream: (req, res) ->
    return res.send("Missing torrent field", 400) unless req.body.torrent
    @startStream req.body.torrent, -> res.redirect "/"

  stopStream: (req, res) ->
    @destroyStream()
    res.redirect "/"

new App