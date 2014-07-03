connect = require "connect"
{Service, middleware} = require "./index"

module.exports = class Server
  constructor: (api, @options) ->
    {@host, @port, @cert, @key, @timeout} = @options
    @host ||= "127.0.0.1"
    @service = new Service api, @options

    # service.simple_dispatcher returns the http handler function
    # used by Connect or the stdlib http server.
    dispatcher = @service.simple_dispatcher(options.handlers)

    @connect = connect()

    @connect.use connect.compress()
    @connect.use middleware.request_encoding()
    @connect.use middleware.json()
    @connect.use dispatcher

  run: ->
    @server = @_create()
    if @timeout
      @server.timeout = @timeout
    @server.listen(@port, @host, @options.tcp_backlog)
    @service.log.info "HTTP server listening on #{@protocol}://#{@host}:#{@port}"

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


