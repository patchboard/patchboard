# HTTP client library
Shred = require("shred")

SchemaManager = require("./schema_manager")

class Client

  @discover: (service_url, handlers) ->
    if service_url.constructor != String
      throw new Error("Expected to receive a String, but got something else")

    create_client = (response) ->
      client = new Client(response.content.data)
      
    if handler = handlers["200"]
      handlers["200"] = (response) ->
        client = new Client(response.content.data)
        handler(client)

    else if handler = handlers["response"]
      handlers["response"] = (response) ->
        client = new Client(response.content.data)
        handler(client)

    new Shred().request
      url: service_url
      method: "GET"
      headers:
        "Accept": "application/json"
      cookieJar: null
      on: handlers



  constructor: (options) ->
    @api = options
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
    @resources = @create_resources(options.extensions, @resource_constructors)
    @directory = @create_directory(options.directory, @resource_constructors)
    for name, spec of options.extensions
      if spec.association
        @associate(spec)


  generate_url: (template, options) ->
    parts = template.split("/")
    out = []
    for part in parts
      if part.indexOf(":") == 0
        key = part.slice(1)
        if string = options[key]
          out.push(string)
        else
          string = "Missing key: '#{key}' in options: #{JSON.stringify(options)}"
          throw new Error(string)
      else
        out.push(part)
    @api.service_url + out.join("/")

  create_resources: (extensions, constructors) ->
    out = {}
    for name, spec of extensions
      out[name] = @create_resource(spec.resource, spec.template)
    out

  create_resource: (name, template) ->
    (options) =>
      constructor = @resource_constructors[name]
      url = @generate_url(template, options)
      return new constructor(url: url)

  associate: (spec) ->
    client = @
    # TODO: error checking
    target = spec.association

    target_constructor = @resource_constructors[target]
    # TODO: handle situation where no identifiers object has been created.
    # TODO: handle situation where named identifier does not exist.
    identify = @identifiers[target]

    extension_constructor = @resource_constructors[spec.resource]

    if target_constructor && extension_constructor
      Object.defineProperty target_constructor.prototype, spec.resource,
        get:  ->
          identifier = identify(@)
          url = client.generate_url(spec.template, identifier)
          new extension_constructor(url: url)


  # Create resource instances using the URLs supplied in the service
  # description's directory.
  create_directory: (directory, constructors) ->
    out = {}
    for key, options of directory
      if constructors[options.resource]
        out[key] = new constructors[options.resource](url: options.url)
    return out

  create_resource_constructors: (definitions) ->
    resource_constructors = {}
    for type, definition of definitions
      constructor = @create_resource_constructor(type, definition)
      resource_constructors[type] = constructor
      if definition.aliases
        for alias in definition.aliases
          resource_constructors[alias] = constructor
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
    (options) ->
      request = @_prepare_request(name, options)
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

    # returns a string that (when logged to console) can be used as the
    # curl command that exactly represents this action.
    curl: (name, options) ->
      request = @_prepare_request(name, options)
      {method, url, headers, content} = request
      agent = headers["User-Agent"]
      command = []
      command.push "curl -v -A '#{agent}' -X #{method}"
      for header, value of headers when header != "User-Agent"
        command.push "  -H '#{header}: #{value}'"

      if content
        command.push "  -d '#{JSON.stringify(content)}'"
      command.push "  #{url}"
      command.join(" \\\n")

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
        headers:
          "User-Agent": "patchboard_client"
        query: options.query
        cookieJar: null
        on: {}
      if options.body
        request.body = options.body
      else if options.content
        request.content = options.content

      # verify presence of the required query params from the schema
      # TODO: check for unexpected params.
      for key, value of definition.query
        if value.required && !request.query
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

      # We only decorate the response content for the handler corresponding
      # to the action definition's "status"
      success_handler = options.on[definition.status]
      if success_handler && response_schema
        request.on[definition.status] = (response) ->
          # TODO: check the Content-Type header
          decorated = client.decorate(response_schema, response.content.data)
          success_handler(response, decorated)
        delete options.on[definition.status]

      # never silently die on request errors.
      # TODO: allow a default request_error handler on Client construction
      request.on.request_error ||= (err) ->
        throw err

      # TODO: figure out how Shred handles 30x and assess whether Patchboard
      # needs to care.

      for status, handler of options.on
        request.on[status] = handler

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
            if result = @decorate(schema.items, item)
              data[i] = result
      else if !SchemaManager.is_primitive(schema.type)
        # Declared properties
        for key, value of schema.properties
          if result = @decorate(value, data[key])
            data[key] = result
        # Default for undeclared properties
        if addprop = schema.additionalProperties
          for key, value of data
            unless schema.properties?[key]
              data[key] = @decorate(addprop, value)
        return data



module.exports = Client
