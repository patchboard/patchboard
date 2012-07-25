Dispatcher = require("./service/simple_dispatcher")

class Service
  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map

  simple_dispatcher: (handlers) ->
    dispatcher = new Dispatcher
      interface: @interface
      schema: @schema
      map: @map
      handlers: handlers
    dispatcher.create_handler()



module.exports = Service
