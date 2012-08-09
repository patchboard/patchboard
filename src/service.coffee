URL = require("url")
PatchboardAPI = require("./patchboard_api")
Dispatcher = require("./service/simple_dispatcher")
Documenter = require("./service/documenter")
SchemaManager = require("./schema_manager")
Path = require("./service/path")

class Service

  constructor: (options) ->
    @service_url = options.service_url || "http://localhost:1337"

    @normalize_schema(PatchboardAPI.schema)
    @normalize_schema(options.schema)

    @schema_manager = new SchemaManager(PatchboardAPI.schema, options.schema)
    @map = options.map


    @interface = {}
    for key, value of PatchboardAPI.interface
      @interface[key] = value
    for key, value of options.interface
      @interface[key] = value

    @directory = {}
    for resource_type, definition of PatchboardAPI.map when definition.publish
      @directory[resource_type] = "#{@service_url}#{definition.paths[0]}"
    for resource_type, definition of @map when definition.publish
      @directory[resource_type] = "#{@service_url}#{definition.paths[0]}"

    @paths = {}
    for resource_type, definition of @map
      path_string = definition.paths[0]
      @paths[resource_type] = new Path(path_string)

    @documenter = new Documenter(@schema_manager.names, @interface)
    @default_handlers = require("./service/handlers")(@)
    @description =
      interface: @interface
      schema: @schema_manager.ids
      schemas: @schema_manager.schemas
      directory: @directory


  generate_url: (resource_type, args...) ->
    path = @paths[resource_type]
    if path
      "#{@service_url}#{path.generate(args...)}"
    else
      throw "Problem generating URL. No such resource: #{resource_type}"

  normalize_schema: (schema) ->
    for name, definition of schema.properties
      if definition.id
        if definition.id.indexOf("#") == 0
          definition.id = "#{schema.id}#{definition.id}"
      else
        definition.id = "#{schema.id}##{name}"

      if definition.extends
        if definition.extends.$ref && definition.extends.$ref.indexOf("#") == 0
          definition.extends.$ref = "#{schema.id}#{definition.extends.$ref}"

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
    
    #{@schema_manager.document()}
    """
  



module.exports = Service
