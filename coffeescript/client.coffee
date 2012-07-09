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
      else if schema.type == "object"
        # This is here because I plan to experiment with defining schemas
        # that aren't resources or dictionaries.
        console.log(
          "Not currently doing anything for an 'object' def:",
          resource_type
        )

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

    constructor = (properties) ->
      # Hide the rigger from console.log
      Object.defineProperty @, "rigger",
        value: rigger
        enumerable: false
      @properties = properties
      null # bless coffeescript.  bless it's little heart.
    constructor.resource_type = resource_type

    constructor.prototype.credential = (type, action) ->
      # TODO: figure out how to have pluggable authorization
      # handlers.  What should happen if the authorization type is
      # Basic?  Other types: Cookie?
      if type == "Capability"
        cap = @properties.capabilities[action]

    for property_name, prop_def of schema.properties
      spec = rigger.property_spec(property_name, prop_def)
      Object.defineProperty(constructor.prototype, property_name, spec)

    interface_def = @interface[resource_type]
    if interface_def
      for name, definition of interface_def.actions
        constructor.prototype[name] = rigger.create_action(name, definition)
    else
      console.warn "No interface defined for resource type: #{resource_type}."

    constructor


  property_spec: (name, def) ->
    rigger = @

    type = def.type
    if type == "object"
      getter = (data) ->
        for prop_name, prop_def of def.properties
          raw = data[prop_name]
          if raw.properties
            raw = raw.properties
          type = prop_def.type
          wrapped = rigger.wrap(type, raw)
          data[prop_name] = wrapped

        data
    else if @wrappers[type]
      getter = (data) ->
        klass = rigger.wrappers[type]
        new klass(data)
    else
      getter = (data) -> data


    spec =
      get: () ->
        val = @properties[name]
        getter(val)
    if !def.readonly
      spec.set = (val) ->
        # TODO: actually make use of schema def
        @properties[name] = val
    spec


  create_action: (name, definition) ->
    rigger = @
    resources = rigger.schemas
    method = definition.method
    if request_schema = definition.request_entity
      request_type = resources[request_schema].media_type
    if response_schema = definition.response_entity
      response_type = resources[response_schema].media_type
    authorization = definition.authorization

    (data) ->
      # FIXME: instead of using data.callback, passthrough
      # the "on" object to the Shred instance.
      callback = data.callback
      delete data.callback
      req =
        url: @url
        method: method
        headers: {}
        content: data
        on:
          response: (response) ->
            wrapped = rigger.wrap(response_schema, response.content.data)
            callback(wrapped)
          error: (r) ->
            console.log "whoops"
      if request_schema
        req.headers["Content-Type"] = request_type
      if response_schema
        req.headers["Accept"] = response_type
      if authorization
        credential = @credential(authorization, name)

        req.headers["Authorization"] = "#{authorization} #{credential}"
      rigger.shred.request(req)

  wrap: (type, data) ->
    if klass = @wrappers[type]
      new klass(data)
    else
      data


module.exports = Client
