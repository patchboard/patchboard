# HTTP client library
Shred = require("shred")

patchboard_api = require("./patchboard_api")
patchboard_interface = patchboard_api.interface
SchemaManager = require("./schema_manager")

class Client

  @discover: (service_url, callback) ->
    if service_url.constructor == String
      new Shred().request
        url: service_url
        method: "GET"
        headers:
          "Accept": "application/json"
        on:
          200: (response) ->
            client = new Client(response.content.data)
            callback(null, client)
          error: (response) ->
            callback(response)
    else
      throw "Expected to receive a String, but got something else"

  # options.schema describes the data structures of
  # the API service resources, and possibly some "helper"
  # constructs (e.g. dictionaries or arrays of resources)
  #
  # options.interface represents the actions available
  # via HTTP requests to the API service.
  constructor: (options) ->
    @shred = new Shred()
    @munged_schema = options.schema
    @schema_manager = new SchemaManager(options.schemas...)
    @directory = options.directory
    @resources = {}

    @interface = {}
    for key, value of patchboard_interface
      @interface[key] = value
    for key, value of options.interface
      @interface[key] = value

    @wrappers = {}

    for resource_type, schema of @munged_schema
      if /^patchboard#/.test(resource_type)
        continue
      if schema.type == "array"
        @wrappers[resource_type] = @array_wrapper(schema)
      else if schema.type == "object"
        @wrappers[resource_type] = @object_wrapper(schema)

    for resource_type, definition of @interface
      if schema = @schema_manager.names[resource_type]
        @wrappers[resource_type] = @resource_wrapper(resource_type, schema)

    @create_resources(@directory)

  create_resources: (directory) ->
    for key, value of directory
      if @wrappers[key]
        @resources[key] = new @wrappers[key](url: value)

  array_wrapper: (schema) ->
    client = @
    item_type = @munge_type(schema.items)
    (items) ->
      result = []
      for value in items
        result.push(client.wrap(item_type, value))
      result

  munge_type: (schema) ->
    if schema.$ref
      schema.$ref.slice(1)
    else if schema.type
      schema.type

  object_wrapper: (schema) ->
    client = @
    (data) ->
      for name, prop_def of schema.properties
        raw = data[name]
        type = client.munge_type(prop_def)
        if type
          wrapped = client.wrap(type, raw)
        else
          wrapped = raw
        data[name] = wrapped
      if schema.additionalProperties
        type = client.munge_type(schema.additionalProperties)
        if type
          for name, raw of data
            # we only want to wrap additional properties
            if !(schema.properties && schema.properties[name])
              data[name] = client.wrap(type, raw)

      data


  # Generate and store a resource class based on the schema
  # and interface
  resource_wrapper: (resource_type, schema) ->
    client = @
    constructor = @resource_constructor()
    # Because coffeescript won't give me Named Function Expressions.
    constructor.resource_type = resource_type

    if interface_def = @interface[resource_type]
      @define_actions(constructor, interface_def.actions)

    # FIXME: Defining properties here is just plain WRONG.  It's the 
    # only reason this method needs to take a schema as an argument
    # at all.  To supply this method with the "correct" schema requires
    # some really atrocious assumptions about the correlation between
    # the interface and the schema naming.
    @define_properties(constructor, schema.properties)
    (data) ->
      new constructor(data)

  define_actions: (constructor, actions) ->
    constructor.prototype.requests = {}
    for name, method of @resource_prototype
      constructor.prototype[name] = method
    for name, definition of actions
      constructor.prototype.requests[name] = @request_creator(name, definition)
      constructor.prototype[name] = @register_action(name)


  define_properties: (constructor, properties) ->
    client = @
    for name, schema of properties
      spec = @property_spec(name, schema)
      Object.defineProperty(constructor.prototype, name, spec)


  property_spec: (name, property_schema) ->
    client = @
    wrap_function = @create_wrapping_function(name, property_schema)

    spec = {}
    spec.get = () ->
      val = @properties[name]
      wrap_function(val)

    if !property_schema.readonly
      spec.set = (val) ->
        # TODO: actually make use of schema def
        @properties[name] = val
    spec

  resource_constructor:  ->
    client = @
    (properties) ->
      # Using Object.defineProperty to hide the client from console.log
      Object.defineProperty @, "client",
        value: client
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
      @client.shred.request(request)

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
    client = @

    method = definition.method
    default_headers = {}
    if request_type = definition.request_entity
      request_media_type = client.schema_manager.names[request_type].mediaType
      default_headers["Content-Type"] = request_media_type
    if response_type = definition.response_entity
      response_media_type = client.schema_manager.names[response_type].mediaType
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

      # NOTE, FIXME, TODO: this entire area is full of early assumptions that
      # turned out to be troublesome.
      # 
      # set up response handlers.  The error and default response handlers
      # do NOT attempt to wrap the response entity per the resource schema.
      request.on = {}
      if error = options.on.error
        request.on.error = error
        delete options.on.error

      if response = options.on.response
        request.on.response = response
        delete options.on.response

      # FIXME:  not all responses should be wrapped.  202 and 204 have no
      # content.  I'm not sure how Shred handles 30x statuses, either.
      for status, handler of options.on
        request.on[status] = (response) ->
          # TODO: disentangle the resource type from the representation type
          wrapped = client.wrap(response_type, response.content.data)
          handler(response, wrapped)

      request

  create_wrapping_function: (name, schema) ->
    client = @
    if schema.type == "object"
      @object_wrapper(schema)
    else if schema.type == "array"
      @array_wrapper(schema)
    else if @wrappers[schema.type]
      (data) -> client.wrap(schema.type, data)
    else
      (data) -> data

  wrap: (type, data) ->
    if wrapper = @wrappers[type]
      wrapper(data)
    else
      data
  




module.exports = Client
