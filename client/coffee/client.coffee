# HTTP client library
Shred = require("shred")

SchemaManager = require("./schema_manager")

class Client

  @discover: (service_url, handlers) ->
    if service_url.constructor != String
      throw new Error("Expected to receive a String, but got something else")

    if handlers.constructor == Function
      @backcompat(service_url, handlers)
    else
      create_client = (response) ->
        client = new Client(response.content.data)
        
      if handler = handlers["200"]
        handlers["200"] = (response) ->
          try
            client = new Client(response.content.data)
            handler(client)
          catch error
            handlers["request_error"](error)

      else if handler = handlers["response"]
        handlers["response"] = (response) ->
          try
            client = new Client(response.content.data)
            handler(client)
          catch error
            handlers["request_error"](error)

      new Shred().request
        url: service_url
        method: "GET"
        headers:
          "Accept": "application/json"
        on: handlers

  @backcompat: (service_url, callback) ->
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
            callback(error)
    else
      throw new Error("Expected to receive a String, but got something else")


  constructor: (options) ->
    @shred = new Shred()

    # Validate API specification
    required_fields = ["schemas", "resources", "directory"]
    missing_fields = []
    for field in required_fields
      unless options[field]
        missing_fields.push(field)

    if missing_fields.length != 0
      throw new Error("API specification is missing fields: #{missing_fields.join(', ')}")

    @schema_manager = new SchemaManager(options.schemas...)
    @authorizer = options.authorizer

    @resource_constructors = @create_resource_constructors(options.resources)
    @resources = @create_resources(options.directory, @resource_constructors)


  # Create resource instances using the URLs supplied in the service
  # description's directory.
  create_resources: (directory, constructors) ->
    resources = {}
    for key, value of directory
      if constructors[key]
        resources[key] = new constructors[key](url: value)
    return resources

  create_resource_constructors: (definitions) ->
    resource_constructors = {}
    for type, definition of definitions
      resource_constructors[type] = @create_resource_constructor(type, definition)
    resource_constructors

  create_resource_constructor: (type, definition) ->
    constructor = (data) ->
      for key, value of data
        @[key] = value
      return @

    constructor.prototype._requests = {}
    constructor.prototype.resource_type = type
    # Hide the Shred client from such things as console.log
    Object.defineProperty constructor.prototype, "patchboard_client",
      value: @
      enumerable: false

    for name, method of @resource_methods
      constructor.prototype[name] = method

    if @authorizer
      constructor.prototype.authorize = @authorizer

    for name, action of definition.actions
      constructor.prototype._requests[name] = @request_creator(name, action)
      constructor.prototype[name] = @register_action(name)
    constructor


  # returns a function intended to be bound to a resource instance
  register_action: (name) ->
    (data) ->
      request = @_prepare_request(name, data)
      @patchboard_client.shred.request(request)

  resource_methods:
    # Method for preparing a request object that can be modified
    # before passing to shred.request().
    #
    #   req = resource._prepare_request "create", {content: "some data"}
    #   req.headers["X-Custom-Whatsit"] =  "Space Monkeys"
    #   shred.request(req)
    _prepare_request: (name, options) ->
      prepper = @_requests[name]
      if prepper
        prepper.call(@, name, options)
      else
        # TODO: catch this error synchronously in the actual request call
        # and relay into the user-supplied error handler.
        throw new Error("No such action defined: #{name}")

    authorize: (type, action) ->
      @patchboard_client.authorizer.call(@, type, action)


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
        query: options.query
        on: {}
      if options.body
        request.body = options.body
      else if options.content
        request.content = options.content

      # verify presence of the required query params from the schema
      for key, value of required_params
        if !request.query || !request.query[key]
          # TODO: catch this error synchronously in the actual request call
          # and relay into the user-supplied error handler.
          throw new Error("Missing required query param: #{key}")

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
            decorated = client.decorate(response_schema, response.content.data)
          handler(response, decorated)

      request

  decorate: (schema, data) ->
    if name = schema.id?.split("#")[1]
      if constructor = @resource_constructors[name]
        data = new constructor(data)
    return @_decorate(schema, data) || data


  _decorate: (schema, data) ->
    if !schema || !data
      return
    if ref = schema.$ref
      if schema = @schema_manager.find(ref)
        @decorate(schema, data)
      else
        console.error "Can't find ref:", ref
        data
    else
      if schema.type == "array"
        if schema.items
          for item, i in data
            data[i] = @decorate(schema.items, item)
      else if !SchemaManager.is_primitive(schema.type)
        # Declared properties
        for key, value of schema.properties
          data[key] = @decorate(value, data[key])
        # Default for undeclared properties
        if addprop = schema.additionalProperties
          for key, value of data
            unless schema.properties?[key]
              data[key] = @decorate(addprop, value)
        return data



module.exports = Client
