# HTTP client library
Shred = require("shred")

class Client

  # options.schema describes the data structures of
  # the API service resources, and possibly some "helper"
  # constructs (e.g. dictionaries or arrays of resources)
  #
  # options.interface represents the actions available
  # via HTTP requests to the API service.
  constructor: (@service_url, options) ->
    @shred = new Shred()
    # Dictionary of wrapper classes
    @schemas = options.schema
    @interface = options.interface

    @wrappers = {}

    # Add placeholder values for all resource types, so the types seen
    # earlier can rely on the existence of types seen later.
    for type, def of @schemas
      @wrappers[type] = "placeholder"

    for resource_type, schema of @schemas
      if schema.type == "resource"
        @wrappers[resource_type] = @resource_wrapper(resource_type, schema)
      else if schema.type == "dictionary"
        @wrappers[resource_type] = @dictionary_wrapper(resource_type, schema)
      else if schema.type == "array"
        @wrappers[resource_type] = @array_handler(schema)
      else if schema.type == "object"
        @wrappers[resource_type] = @object_handler(schema)

  array_handler: (schema) ->
    rigger = @
    item_type = schema.items.type
    out =
      type: "array"
      handle: (items) ->
        result = []
        for value in items
          result.push(rigger.wrap(item_type, value))
        result
    out

  object_handler: (schema) ->
    rigger = @
    out =
      type: "object"
      handle: (data) ->
        for name, prop_def of schema.properties
          raw = data[name]
          type = prop_def.type
          wrapped = rigger.wrap(type, raw)
          data[name] = wrapped
        data
    out


  dictionary_wrapper: (resource_type, schema) ->
    rigger = @

    item_type = schema.items.type
    constructor = (items) ->
      # wrap all members of the input object with the appropriate
      # resource class.
      for name, value of items
        raw = items[name]
        @[name] = rigger.wrap(item_type, raw)
      null
    constructor.resource_type = resource_type
    constructor


  # Generate and store a resource class based on the schema
  # and interface
  resource_wrapper: (resource_type, schema) ->
    rigger = @

    constructor = @resource_constructor()
    # Because coffeescript won't give me Named Function Expressions.
    constructor.resource_type = resource_type

    interface_def = @interface[resource_type]
    if interface_def
      for name, method of @resource_prototype
        constructor.prototype[name] = method

      # Set up the request-preparing and firing methods.
      constructor.prototype.requests = {}
      for name, definition of interface_def.actions
        constructor.prototype.requests[name] = @request_creator(name, definition)
        constructor.prototype[name] = @register_action(name)
    else
      console.log "WARNING: No interface defined for resource type: #{resource_type}."

    for property_name, prop_def of schema.properties
      spec = @property_spec(property_name, prop_def)
      Object.defineProperty(constructor.prototype, property_name, spec)

    constructor

  resource_constructor:  ->
    rigger = @
    (properties) ->
      # Using Object.defineProperty to hide the rigger from console.log
      Object.defineProperty @, "rigger",
        value: rigger
        enumerable: false
      @properties = properties
      null # bless coffeescript.  bless it's little heart.

  resource_prototype:
    # Method for preparing a request object that can be modified
    # before passing to shred.request().
    #
    #   req = resource.prepare_request "create", {content: "some data"}
    #   req.headers["X-Custom-Whatsit"] =  "Space Monkeys"
    #   shred.request(req)
    prepare_request: (name, options) ->
      prepper = @requests[name]
      if prepper
        prepper.call(@, name, options)
      else
        throw "No such action defined: #{name}"

    request: (name, options) ->
      request = @prepare_request(name, options)
      @rigger.shred.request(request)

    credential: (type, action) ->
      # TODO: figure out how to have pluggable authorization
      # handlers.  What should happen if the authorization type is
      # Basic?  Other types: Cookie?
      if type == "Capability"
        cap = @properties.capabilities[action]


  register_action: (name) ->
    (data) -> @request(name, data)

  # Returns a function intended to be used as a method on a
  # Resource wrapper instance.
  request_creator: (name, definition) ->
    rigger = @

    method = definition.method
    default_headers = {}
    if request_type = definition.request_entity
      request_media_type = rigger.schemas[request_type].media_type
      default_headers["Content-Type"] = request_media_type
    if response_type = definition.response_entity
      response_media_type = rigger.schemas[response_type].media_type
      default_headers["Accept"] = response_media_type
    authorization = definition.authorization
    if query = definition.query
      required_params = query.required

    (name, options) ->
      request =
        url: @url
        method: method
        headers: {}
        content: options.content

      # set up headers
      for key, value of default_headers
        request.headers[key] = value

      if authorization
        credential = @credential(authorization, name)
        request.headers["Authorization"] = "#{authorization} #{credential}"

      for name, value of options.headers
        request.headers[name] = value

      if options.query
        request.query = options.query

      # verify presence of the required query params from the schema
      for key, value of required_params
        if !request.query[key]
          throw "Missing required query param: #{key}"

      # set up response handlers.  The error and default response handlers
      # do NOT attempt to wrap the response entity per the resource schema.
      request.on = {}
      if error = options.on.error
        request.on.error = error
        delete options.on.error

      if response = options.on.response
        request.on.response = response
        delete options.on.response

      for status, handler of options.on
        request.on[status] = (response) ->
          wrapped = rigger.wrap(response_type, response.content.data)
          handler(response, wrapped)

      request

  property_spec: (name, property_schema) ->
    rigger = @
    wrap_function = @create_wrapping_function(property_schema)

    spec = {}
    spec.get = () ->
      val = @properties[name]
      wrap_function(val)

    if !property_schema.readonly
      spec.set = (val) ->
        # TODO: actually make use of schema def
        @properties[name] = val
    spec

  create_wrapping_function: (schema) ->
    rigger = @
    if schema.type == "object"
      @object_handler(schema).handle
    else if schema.type == "array"
      @array_handler(schema).handle
    else if @wrappers[schema.type]
      (data) -> new rigger.wrappers[schema.type](data)
    else
      (data) -> data

  wrap: (type, data) ->
    if wrapper = @wrappers[type]
      if typeof(wrapper) == "function"
        new wrapper(data)
      else if wrapper == "placeholder"
        throw "No wrapper or handler defined for resource type: #{type}"
      else
        wrapper.handle(data)
    else
      data
  




module.exports = Client
