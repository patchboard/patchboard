Shred = require("shred")

rigger_schema = require("../rigger-schema")

class Client

  # options.schema describes the data structures of
  # the API service resources, and possibly some "helper"
  # constructs (e.g. dictionaries or arrays of resources)
  #
  # options.interface represents the actions available
  # via HTTP requests to the API service.
  constructor: (@service_url, options) ->
    @shred = new Shred()
    @resources = {}
    @schema =
      rigger: rigger_schema
      resources: options.schema
    @interface = options.interface

    @resource_keys = {}
    for name, def of @schema.resources
      @resource_keys[name] = true
    for resource_name, schema_def of @schema.resources
      # NOTE: I've silently introduced two pseudo-primitive types to the
      # pidgin JSON schema I'm using.  "resource" is a type that must have
      # a "url" property "dictionary" is an object-based type, the properties
      # of which must all contain values of the type specified by the "items"
      # value of the schema.
      if schema_def.type == "resource"
        @generate_resource_class(resource_name, schema_def)
      else if schema_def.type == "dictionary"
        @generate_dictionary_class(resource_name, schema_def)
      else if schema_def.type == "object"
        console.log("Not doing anything for an 'object' def:", resource_name)

  generate_dictionary_class: (resource_name, schema_def) ->
    rigger = @

    item_type = schema_def.items.type
    klass = (items) ->
      # wrap all members of the input object with the appropriate
      # resource class.
      for name, value of items
        raw = items[name]
        @[name] = rigger.wrap(item_type, raw)
      null
    klass.resource_name = resource_name
    @resources[resource_name] = klass


  # Generate and store a resource class based on the schema
  # and interface
  generate_resource_class: (resource_name, schema_def) ->
    rigger = @
    interface_def = @interface[resource_name]
    constructor = @generate_constructor()

    # NOTE: this is a crappy way to generate a constructor/class,
    # and should later be changed to simply create the function
    # manually.  I'm doing this now because I suspect I might want
    # to use the CoffeeScript inheritance feature during initial
    # development.
    @resources[resource_name] = class GeneratedResource extends Resource
      # Set the resource name in the constructor so we can reflect on 
      # it later, if necessary.
      @resource_name = resource_name

      # Set the constructor to the function created above
      constructor: constructor

      credential: (type, action) ->
        # TODO: figure out how to have pluggable authorization
        # handlers.  What should happen if the authorization type is
        # Basic?  Other types: Cookie?
        if type == "Capability"
          cap = @properties.capabilities[action]

      for property_name, prop_def of schema_def.properties
        spec = {}
        get_wrapper = rigger.wrapper(property_name, prop_def.type, prop_def)
        spec.get = rigger.define_props(property_name, get_wrapper)

        # FIXME: this needs to be in the define_props method
        if !prop_def.readonly
          spec.set = (val) ->
            @properties[property_name] = val

        Object.defineProperty(@prototype, property_name, spec)

      if interface_def
        for name, definition of interface_def.actions
          @prototype[name] = rigger.generate_action(name, definition)


  generate_action: (name, definition) ->
    rigger = @
    resources = rigger.schema.resources
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

  define_props: (name, get_wrapper) ->
    () ->
      val = @properties[name]
      get_wrapper(val)

  wrap: (type, data) ->
    if klass = @resources[type]
      new klass(data)
    else
      data

  wrapper: (name, type, def) ->
    rigger = @
    exists = @resource_keys[type]
    # TODO: move all this into the definition of
    # resources for the rigger.  We should always
    # handle objects this way.
    if type == "object"
      (data) ->
        for prop_name, prop_def of def.properties
          raw = data[prop_name]
          if raw.properties
            raw = raw.properties
          type = prop_def.type
          wrapped = rigger.wrap(type, raw)
          data[prop_name] = wrapped

        data
    else if exists
      (data) ->
        klass = rigger.resources[type]
        new klass(data)
    else
      (data) -> data

  generate_constructor: ->
    rigger = @

    (properties) ->
      # Hide the rigger from console.log
      Object.defineProperty @, "rigger",
        value: rigger
        enumerable: false

      @properties = properties
      if @wrap_data
        @properties = @wrap_data(@properties)



class Resource
  #credential: (type, action) ->
    ## TODO: figure out how to have pluggable authorization
    ## handlers.  What should happen if the authorization type is
    ## Basic?  Other types: Cookie?
    #if type == "Capability"
      #cap = @properties.capabilities[action]

module.exports = Client
