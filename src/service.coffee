Dispatcher = require("./service/simple_dispatcher")
Documenter = require("./service/documenter")

class Service
  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map
    @documenter = new Documenter(@schema, @interface)

  simple_dispatcher: (handlers) ->
    dispatcher = new Dispatcher(@, handlers)
    dispatcher.create_handler()


  documentation: () ->
    """
    #{@documenter.document_interface()}
    
    #{@documenter.document_schema()}
    """


module.exports = Service
