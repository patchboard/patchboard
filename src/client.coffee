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
    @schema_manager = new SchemaManager(options.schemas...)
    @directory = options.directory
    @resources = {}

    @interface = {}
    for key, value of patchboard_interface
      @interface[key] = value
    for key, value of options.interface
      @interface[key] = value

    @representation_ids = {}
    @representation_types = {}
    @resource_constructors = {}

    for name, schema of @schema_manager.names
      if schema.type == "array"
        constructor = @array_wrapper(schema)
        @representation_ids[schema.id] = constructor
      else
        constructor = @representation_constructor(schema)
        @representation_ids[schema.id] = constructor

    for resource_type, definition of @interface
      for id, constructor of @representation_ids
        # The assumption here is that the frag-ident part of a schema id
        # corresponds to the resource type.
        [base, name] = id.split("#")
        if name == resource_type
          constructor = @resource_constructor(constructor, resource_type)
          @representation_ids[id] = constructor
          @resource_constructors[resource_type] = constructor

      # create a resource constructor for types with no directly associated schemas.
      @resource_constructors[resource_type] ||= @resource_constructor(null, resource_type)

    @create_resources(@directory)

  # Create resource instances using the URLs supplied in the service
  # description's directory.
  create_resources: (directory) ->
    for key, value of directory
      if @resource_constructors[key]
        @resources[key] = new @resource_constructors[key](url: value)

  array_wrapper: (schema) ->
    client = @
    item_type = @determine_schema_type(schema.items)
    # NOTE: this works as a constructor because of ECMA-262 3rd Edition,
    # sections 11.2.2 and 13.2.2. In short, if a function used as a constructor
    # returns an Object, then the constructor call will return that object.
    #
    # I'm doing this for a couple of reasons:
    #
    # * client.wrap assumes the functions it uses are all constructors
    # * subclassing Array in JavaScript is not practical.
    (items) ->
      result = []
      for value in items
        result.push(client.wrap(item_type, value))
      result

  object_wrapper: (schema) ->
    client = @
    (data) ->
      for name, prop_def of schema.properties
        raw = data[name]
        type = client.determine_schema_type(prop_def)
        if type
          wrapped = client.wrap(type, raw)
        else
          wrapped = raw
        data[name] = wrapped
      if schema.additionalProperties
        type = client.determine_schema_type(schema.additionalProperties)
        if type
          for name, raw of data
            # we only want to wrap additional properties
            if !(schema.properties && schema.properties[name])
              data[name] = client.wrap(type, raw)

      data

  determine_schema_type: (schema) ->
    if schema.$ref
      if schema.$ref.indexOf("#") == 0
        schema.$ref.slice(1)
      else
        schema.$ref
    else if schema.type
      schema.type

  wrap: (type, data) ->
    if wrapper = @representation_ids[type]
      new wrapper(data)
    else
      console.log "no wrapper found for", type
      data
  
  resource_constructor: (constructor, resource_type) ->
    client = @
    constructor ||= (@properties) ->
      @url = @properties.url
    # Because coffeescript won't give me Named Function Expressions.
    constructor.resource_type = resource_type
    # Using Object.defineProperty to hide the client from console.log
    Object.defineProperty constructor.prototype, "client",
      value: client
      enumerable: false
    if interface_def = @interface[resource_type]
      @define_actions(constructor, interface_def.actions)
    constructor

  define_actions: (constructor, actions) ->
    constructor.prototype.requests = {}
    for name, method of @resource_methods
      constructor.prototype[name] = method
    for name, definition of actions
      constructor.prototype.requests[name] = @request_creator(name, definition)
      constructor.prototype[name] = @register_action(name)


  representation_constructor: (schema) ->
    client = @
    constructor = (@properties) ->
    @define_properties(constructor, schema.properties)
    constructor

  define_properties: (constructor, properties) ->
    client = @
    for name, schema of properties
      spec = @property_spec(name, schema)
      Object.defineProperty(constructor.prototype, name, spec)

  property_spec: (name, property_schema) ->
    client = @
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
    client = @
    type = schema.type
    if schema.$ref
      (data) -> client.wrap(schema.$ref, data)
    else if type == "object"
      @object_wrapper(schema)
    else if type == "array"
      @array_wrapper(schema)
    else
      (data) -> data


  resource_methods:
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
      response_schema = client.schema_manager.names[response_type]
      response_media_type = response_schema.mediaType
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

      # NOTE: this entire area is full of early assumptions that
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
      # IDEA: take an "on" option of "success", to be applied when the
      # response status matches the indicated status in the API interface.
      for status, handler of options.on
        request.on[status] = (response) ->
          # TODO: disentangle the resource type from the representation type
          if response.status == definition.status
            wrapped = client.wrap(response_schema.id, response.content.data)
          handler(response, wrapped)

      request





module.exports = Client
