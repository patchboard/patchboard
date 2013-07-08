connect = require "connect"
Service = require "./server/service"
middleware = require "./server/middleware"

module.exports = class Server
  constructor: (api, @options) ->
    {@host, @port, @cert, @key} = @options
    @host ||= "127.0.0.1"
    @service = new Service api, @options

    # service.simple_dispatcher returns the http handler function
    # used by Connect or the stdlib http server.
    dispatcher = @service.simple_dispatcher(options.handlers)

    @connect = connect()

    @connect.use(@error_check())
    @connect.use(connect.compress())
    @connect.use(middleware.request_encoding())
    @connect.use(middleware.json())
    @connect.use(dispatcher)

  error_check: ->
    (request, response, next) =>
      # TODO: CORS handling.  Will require manually constructing response,
      # rather than using next(error).
      if @status != "ok"
        error = new Error @status
        error.status = 500
        delete error.stack
        next(error)
      else
        next()

  _create: ->
    if @cert && @key
      @protocol = "https"
      @server = require("https").createServer(
        {key: @key, cert: @cert},
        @connect
      )
    else
      @protocol = "http"
      @server = require("http").createServer(@connect)

  run: ->
    @status = "ok"
    @server = @_create()
    @server.listen(@port, @host)
    console.log("HTTP server listening on #{@protocol}://#{@host}:#{@port}")


