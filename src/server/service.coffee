URL = require("url")

PatchboardAPI = require("./patchboard_api")
Dispatcher = require("./simple_dispatcher")
Documenter = require("./documenter")
Classifier = require("./classifier")
SchemaManager = require("./schema_manager")
SchemaValidator = require("./schema_validator")
Path = require("./path")

class Service

  constructor: (api, @options={}) ->
    url = @options.url || "http://localhost:1337"

    # We construct full urls by concatenating @service_url and the path,
    # so make sure that @service_url does not end in a slash.
    if url[url.length-1] == "/"
      url = url.slice(0,-1)
    @service_url = url

    SchemaManager.normalize(PatchboardAPI.schema)
    SchemaManager.normalize(api.schema)

    @schema_manager = new SchemaManager(PatchboardAPI.schema, api.schema)
    unless @options.validate == false
      @validator = new SchemaValidator(@schema_manager)
    @map = api.paths

    @response_decorator = @options.response_decorator

    @resources = {}
    for key, value of PatchboardAPI.resources
      @resources[key] = value
    for key, value of api.resources
      @resources[key] = value

    @paths = {}
    @directory = {}

    for resource_type, mapping of PatchboardAPI.paths when mapping.publish
      @directory[resource_type] = "#{@service_url}#{mapping.path}"
    for resource_type, mapping of @map when mapping.publish
      @directory[resource_type] = "#{@service_url}#{mapping.path}"

    for resource_type, mapping of @map
      path_string = mapping.path
      @paths[resource_type] = new Path(path_string)

    @documenter = new Documenter(@schema_manager.names, @resources)
    @default_handlers = require("./handlers")(@)

    @classifier = new Classifier(@)

    @description =
      resources: @resources
      schemas: @schema_manager.schemas
      directory: @directory


  classify: (args...) ->
    @classifier.classify(args...)

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
      if definition.type == "array" && definition.items.$ref.indexOf("#") == 0
        definition.items.$ref = "#{schema.id}#{definition.items.$ref}"


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

  parse_url: (url) ->
    parsed = URL.parse(url, true)
    parsed.path = parsed.pathname = parsed.pathname.replace("//", "/")
    parsed


  augment_request: (request) ->
    url = @parse_url(request.url)
    request.path = url.pathname
    request.query = url.query

  documentation: () ->
    """
    #{@documenter.document_resources()}
    
    #{@schema_manager.document()}
    """
  
  smurfy: (schema, data) ->
    @service.response_decorator(@, schema, data)
    @_decorate(schema, data)

  decorate: (context, schema, data) ->
    if @response_decorator
      @response_decorator(context, schema, data)
    @_decorate(context, schema, data)

  _decorate: (context, schema, data) ->
    if !schema || !data
      return
    if ref = schema.$ref
      if schema = @schema_manager.find(ref)
        @decorate(context, schema, data)
      else
        console.error "Can't find ref:", ref
        data
    else
      if schema.type == "array"
        if schema.items
          for item, i in data
            @decorate(context, schema.items, item)
      else if !SchemaManager.is_primitive(schema.type)
        # Declared properties
        for key, value of schema.properties
          @decorate(context, value, data[key])
        # Default for undeclared properties
        if addprop = schema.additionalProperties
          for key, value of data
            unless schema.properties?[key]
              @decorate(context, addprop, value)
        return data


module.exports = Service
