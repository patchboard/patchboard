connect = require "connect"
Service = require "./service"
middleware = require "./middleware"

module.exports = class Server
  constructor: (api, options) ->
    {@host, @port, url, validate} = options
    @service = new Service api,
      url: url
      validate: validate

    # service.simple_dispatcher returns the http handler function
    # used by Connect or the stdlib http server.
    dispatcher = @service.simple_dispatcher(options.handlers)

    @connect = connect()
    @connect.use(connect.compress())
    @connect.use(middleware.request_encoding())
    @connect.use(middleware.json())
    @connect.use(dispatcher)

  run: ->
    @connect.listen(@port, @host)
    console.log("HTTP server listening on #{@host}:#{@port}")

