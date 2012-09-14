# HTTP client library
Shred = require("shred")

patchboard_api = require("./patchboard_api")
patchboard_resources = patchboard_api.resources
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
          request_error: (error) ->
            throw error
    else
      throw "Expected to receive a String, but got something else"


  constructor: (options) ->
    @shred = new Shred()
    @schema_manager = new SchemaManager(options.schemas...)
    @directory = options.directory
    @authorizer = options.authorizer
    @resources = {}

    @resource_definitions = {}
    for key, value of patchboard_resources
      @resource_definitions[key] = value
    for key, value of options.resources
      @resource_definitions[key] = value

    @representation_ids = {}
    @resource_constructors = {}

    for id, schema of @schema_manager.ids
      if schema.type == "array"
        constructor = @array_wrapper(schema)
        @representation_ids[schema.id] = constructor
      else if schema.type == "object"
        constructor = @object_wrapper(schema)
        @representation_ids[schema.id] = constructor
      else if !SchemaManager.is_primitive(schema.type)
        constructor = @representation_constructor(schema)
        @representation_ids[schema.id] = constructor

    for resource_type, definition of @resource_definitions
      for id, constructor of @representation_ids
        # The assumption here is that the frag-ident part of a schema id
        # corresponds to the resource type.
        [base, name] = id.split("#")
        if name == resource_type
          @resourcify(constructor, resource_type)
          @resource_constructors[resource_type] = constructor

      # create a resource constructor for types with no directly associated schemas.
      @resource_constructors[resource_type] ||= @resourcify(null, resource_type)

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
      data
  
  representation_constructor: (schema) ->
    constructor = (@properties) ->
    @define_properties(constructor, schema.properties)
    constructor

  define_properties: (constructor, properties) ->
    for name, schema of properties
      spec = @property_spec(name, schema)
      Object.defineProperty(constructor.prototype, name, spec)

  property_spec: (name, property_schema) ->
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




  resourcify: (constructor, resource_type) ->
    client = @
    constructor ||= (@properties) ->
      @url = @properties.url

    # Because coffeescript won't give me Named Function Expressions.
    constructor.prototype.resource_type = resource_type
    constructor.prototype.requests = {}

    # Using Object.defineProperty to hide the client from console.log
    Object.defineProperty constructor.prototype, "client",
      value: client
      enumerable: false

    if definition = @resource_definitions[resource_type]
      @define_actions(constructor, definition.actions)

    constructor

  define_actions: (constructor, actions) ->
    for name, method of @resource_methods
      constructor.prototype[name] = method
    if @authorizer
      constructor.prototype.authorize = @authorizer
    for name, definition of actions
      constructor.prototype.requests[name] = @request_creator(name, definition)
      constructor.prototype[name] = @register_action(name)

  # returns a function intended to be bound to a resource instance
  register_action: (name) ->
    (data) -> @request(name, data)

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
        # TODO: hook into the "error" handler that should be defined
        # in options.on.  Possibly have the Client constructor take
        # a default error handler as an argument.
        throw "No such action defined: #{name}"

    request: (name, options) ->
      request = @prepare_request(name, options)
      @client.shred.request(request)

    authorize: (type, action) ->
      @client.authorizer.call(@, type, action)


  # Returns a function intended to be used as a method on a
  # Resource instance.
  request_creator: (name, definition) ->
    client = @

    method = definition.method
    default_headers = {}
    if request_type = definition.request_schema
      request_media_type = client.schema_manager.find(request_type).mediaType
      default_headers["Content-Type"] = request_media_type
    # FIXME:  we should also check for definition.accept
    if response_type = definition.response_schema
      response_schema = client.schema_manager.find(response_type)
      response_media_type = response_schema.mediaType
      default_headers["Accept"] = response_media_type
    authorization = definition.authorization
    if query = definition.query
      required_params = query.required

    (name, options) ->
      resource = @
      request =
        url: resource.url
        method: method
        headers: {}
        content: options.content
        query: options.query
        on: {}

      # verify presence of the required query params from the schema
      for key, value of required_params
        if !request.query || !request.query[key]
          throw "Missing required query param: #{key}"

      if authorization
        credential = resource.authorize(authorization, name)
        request.headers["Authorization"] = "#{authorization} #{credential}"

      # copy default headers
      for key, value of default_headers
        request.headers[key] = value

      # Input headers should override the defaults determined from the API spec.
      for key, value of options.headers
        request.headers[key] = value

      # Pass through status handlers for which we shouldn't wrap the response
      # body.  202 and 204 don't have bodies.  Errors won't contain the expected
      # representation. I actually want for the default "response" handler to
      # do body wrapping when appropriate, but...
      # FIXME: I can't figure out why, but if I don't do the hokey pokey with
      # the default "response" handler here, Shred selects it over specific
      # status code handlers. Might be a Shred bug.
      for status in [202, 204, "error", "request_error", "response"]
        if handler = options.on[status]
          request.on[status] = handler
          delete options.on[status]


      # never silently die on request errors.
      # TODO: allow a default request_error handler on Client construction
      request.on.request_error ||= (err) ->
        throw err

      # TODO: figure out how Shred handles 30x and assess whether Patchboard
      # needs to care.
      # IDEA: take an "on" option of "success", to be applied when the
      # response status matches the indicated status in the resource description.
      for status, handler of options.on
        request.on[status] = (response) ->
          # TODO: check the Content-Type header
          if response.status == definition.status && response_schema
            wrapped = client.wrap(response_schema.id, response.content.data)
          handler(response, wrapped)

      request



module.exports = Client
