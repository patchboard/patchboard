connect = require "connect"
{Service, middleware} = require "./index"
SimpleDispatcher = require("./dispatchers/simple")

module.exports = class Server
  constructor: (@listener, @options) ->
    {@host, @port, @cert, @key, @timeout, @tcp_backlog} = @options
    @host ||= "127.0.0.1"

    @connect = connect()

    @connect.use connect.compress()
    @connect.use middleware.request_encoding()
    @connect.use middleware.json()
    @connect.use @listener

  run: ->
    @server = @_create()
    if @timeout
      @server.timeout = @timeout

    # http://nodejs.org/api/http.html#http_server_listen_port_hostname_backlog_callback
    @server.listen(@port, @host, @tcp_backlog)
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


