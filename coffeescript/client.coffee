Shred = require("shred")

#string = fs.readFileSync("../rigger-schema.json")
#rigger_schema = JSON.parse(string)
rigger_schema = require("../rigger-schema")

class Client

  class Dictionary

  constructor: (@service_url, options) ->
    @shred = new Shred()
    @resources = {}
    # The schema object describes the data structures of
    # the API service resources, and possibly some "helper"
    # constructs (e.g. dictionaries or arrays of resources)
    @schema =
      rigger: rigger_schema
      resources: options.schema
    # The interface object represents the actions available
    # via HTTP requests to the API service.
    @interface = options.interface

    @resource_keys = {}
    for name, def of @schema.resources
      @resource_keys[name] = true
    for resource_name, schema_def of @schema.resources
      if schema_def.type == "resource"
        @generate_resource_class(resource_name, schema_def)
      else if schema_def.type == "dictionary"
        @generate_dictionary_class(resource_name, schema_def)

  generate_dictionary_class: (resource_name, schema_def) ->
    rigger = @
    @resources[resource_name] = class GeneratedDictionary extends Dictionary
      @resource_name = resource_name
      item_type = schema_def.items.type
      constructor: (items) ->
        for name, value of items
          raw = items[name]
          @[name] = rigger.wrap(item_type, raw)




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

      for property_name, prop_def of schema_def.properties
        spec = {}

        type = prop_def.type
        get_wrapper = rigger.wrapper(property_name, type, prop_def)
        spec.get = rigger.define_props(property_name, get_wrapper)

        # FIXME: this needs to be in the define_props method
        if !prop_def.readonly
          spec.set = (val) ->
            @properties[property_name] = val

        Object.defineProperty @prototype, property_name, spec


      if interface_def
        try
          @process_interface(interface_def)
        catch e
          console.log(resource_name, schema_def, interface_def)
          throw e

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

  #session:
    #type: "object"
    #media_type: "application/vnd.spire-io.session+json;version=1.0"
    #properties:
      #url: {type: "string"}
      #capabilities: {type: "capability_dictionary"}
      #resources:
        #type: "object"
        #properties:
          #account: {type: "account"}
          #channels: {type: "channel_collection"}
  @process_interface: (definition) ->
    for action_name, action_def of definition.actions
      @define_action(action_name, action_def)

  @process_schema: (rigger, definition) ->
    for property_name, prop_def of definition.properties
      @simple_property(property_name, prop_def)

  @simple_property: (property_name, definition) ->
    spec = {}
    spec["get"] = @define_getter(property_name, definition)
    if !definition.readonly
      spec["set"] = (val) ->
        @properties[property_name] = val
    Object.defineProperty @prototype, property_name, spec

  @define_getter: (name, definition) ->
    type = definition.type
    () ->
      #console.log("getter for", name, type)
      val = @properties[name]
      @rigger.wrap(type, val)

      

  @define_action: (action_name, definition) ->
    @prototype[action_name] = (data) ->
      rigger = @rigger
      resource = @
      callback = data.callback
      delete data.callback

      request = {}
      request.headers = headers = {}

      request_type = definition.request_entity
      response_type = definition.response_entity
      headers = {}
      if request_type
        headers["Content-Type"] = rigger.schema.resources[request_type].media_type
      if response_type
        headers["Accept"] = rigger.schema.resources[response_type].media_type
      if definition.authorization
        auth_type = definition.authorization
        credential = @credential(auth_type, action_name)
        headers["Authorization"] = "#{auth_type} #{credential}"


      rigger.shred.request
        url: @properties.url
        method: definition.method
        headers: headers
        content: data
        on:
          response: (response) ->
            wrapped = rigger.wrap(response_type, response.content.data)
            callback(wrapped)
          error: (r) ->
            console.log "whoops"

  # TODO: figure out how to have pluggable authorization
  # handlers.  What should happen if the authorization type is
  # Basic?  Other types: Cookie?
  credential: (type, action) ->
    if type == "Capability"
      cap = @properties.capabilities[action]

module.exports = Client
