Dispatcher = require("./service/simple_dispatcher")
Documenter = require("./service/documenter")

class Service
  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map
    @documenter = new Documenter(@schema, @interface)
    @default_handlers = require("./service/handlers")(@)

  simple_dispatcher: (handlers) ->

    # Install Patchboard's default handlers
    for resource, actions of @default_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] ||= handler

    dispatcher = new Dispatcher(@, handlers)
    dispatcher.create_handler()


  documentation: () ->
    """
    #{@documenter.document_interface()}
    
    #{@documenter.document_schema()}
    """


module.exports = Service
