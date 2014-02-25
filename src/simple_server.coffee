connect = require "connect"
Service = require "./service"
Server = require "./server"
Dispatcher = require("./dispatchers/simple")
middleware = require "./middleware"

module.exports = class SimpleServer extends Server
  constructor: (api, options) ->
    {url, log, validate, decorator, handlers} = options
    delete options.handlers

    @service = new Service api, options
    dispatcher = new Dispatcher(@service, handlers)
    listener = dispatcher.request_listener()

    super(listener, options)


