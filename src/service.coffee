URL = require("url")
PatchboardAPI = require("./patchboard_api")
Dispatcher = require("./service/simple_dispatcher")
Documenter = require("./service/documenter")
Path = require("./service/path")

class Service

  constructor: (options) ->
    @service_url = options.service_url || "http://localhost:1337"
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
      @directory[resource_type] = "#{@service_url}#{definition.paths[0]}"
    for resource_type, definition of options.map when definition.publish
      @directory[resource_type] = "#{@service_url}#{definition.paths[0]}"

    @interface = options.interface
    @map = options.map
    @documenter = new Documenter(@schema, @interface)

    @paths = {}
    for resource_type, definition of @map
      path_string = definition.paths[0]
      @paths[resource_type] = new Path(path_string)

    @description =
      interface: @interface
      schema: @schema
      directory: @directory


  generate_url: (resource_type, args...) ->
    path = @paths[resource_type]
    if path
      "#{@service_url}#{path.generate(args...)}"
    else
      throw "Problem generating URL. No such resource: #{resource_type}"


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

  augment_request: (request) ->
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
