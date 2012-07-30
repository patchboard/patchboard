URL = require("url")
PatchboardAPI = require("./patchboard_api")
Dispatcher = require("./service/simple_dispatcher")
Documenter = require("./service/documenter")

class Service

  constructor: (options) ->
    @base_url = options.url || "http://localhost:1337"
    @schema = {properties: {}}
    @interface = {}
    @directory = {}
    @default_handlers = require("./service/handlers")(@)

    for key, value of PatchboardAPI.schema.properties
      @schema.properties[key] = value
    for key, value of options.schema.properties
      @schema.properties[key] = value

    for key, value of PatchboardAPI.interface
      @interface[key] = value
    for key, value of options.interface
      @interface[key] = value

    for resource_type, definition of PatchboardAPI.map when definition.publish
      @directory[resource_type] = "#{@base_url}#{definition.paths[0]}"
    for resource_type, definition of options.map when definition.publish
      @directory[resource_type] = "#{@base_url}#{definition.paths[0]}"

    @interface = options.interface
    @map = options.map
    @documenter = new Documenter(@schema, @interface)
    @description =
      interface: @interface
      schema: @schema
      directory: @directory


  simple_dispatcher: (app_handlers) ->
    handlers = {}

    # Install Patchboard's default handlers
    for resource, actions of @default_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    for resource, actions of app_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    dispatcher = new Dispatcher(@, handlers)
    dispatcher.create_handler()

  improve_request: (request) ->
    url = URL.parse(request.url)
    request.path = url.pathname
    if url.query
      query_parts = url.query.split("&")
      query = {}
      for part in query_parts
        [key, value] = part.split("=")
        query[key] = value
    else
      query = {}
    request.query = query

  documentation: () ->
    """
    #{@documenter.document_interface()}
    
    #{@documenter.document_schema()}
    """


module.exports = Service
