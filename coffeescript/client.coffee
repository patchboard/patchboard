Shred = require("shred")

class Client

  constructor: (@service_url, options) ->
    @shred = new Shred()
    @resources = {}
    @schema = options.schema
    @interface = options.interface

    rigger = @
    shred = @shred
    schema = @schema

    for resource_name, schema_def of @schema
      interface_def = @interface[resource_name]
      @resources[resource_name] = class extends Resource
        @resource_name = resource_name

        constructor: (properties) ->
          @rigger = rigger
          @properties = properties
          if @wrap_data
            @properties = @wrap_data(@properties)

        @setup_schema(rigger, schema_def)

        if interface_def
          try
            @setup_interface(interface_def)
          catch e
            console.log(resource_name, schema_def, interface_def)
            throw e

  

class Resource
  constructor: () ->

  @setup_interface: (definition) ->
    for action_name, action_def of definition.actions
      @define_action(action_name, action_def)

  #account:
    #type: "resource"
    #media_type: "application/vnd.spire-io.account+json;version=1.0"
    #properties:
      #id: {type: "string", readonly: true}
      #secret: {type: "string", readonly: true}
      #created_at: {type: "number"}
      #email: {type: "string"}
      #name: {type: "string"}
      #password: {type: "string"}
    #required: ["email", "password"]

  #channel_dictionary:
    #type: "dictionary"
    #media_type: "application/vnd.spire-io.channels+json;version=1.0"
    #items: {type: "channel"}

  @setup_schema: (rigger, definition) ->
    if definition.type == "dictionary"
      item_type = definition.items.type
      if klass = rigger.resources[item_type]
        @prototype.wrap_data = (data) ->
          out = {}
          for key, value of data
            out[key] = new klass(value)
          out
    else
      for property_name, prop_def of definition.properties
        @simple_property(property_name, prop_def)

  @simple_property: (property_name, definition) ->
    spec = {}
    spec["get"] = ->
      @properties[property_name]
    if !definition.readonly
      spec["set"] = (val) ->
        @properties[property_name] = val
    Object.defineProperty @prototype, property_name, spec
      

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
        headers["Content-Type"] = rigger.schema[request_type].media_type
      if response_type
        headers["Accept"] = rigger.schema[response_type].media_type
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
            data = response.content.data
            klass = rigger.resources[response_type]
            if klass
              data = new klass(data)
            callback(data)
          error: (r) ->
            console.log "whoops"

  # TODO: figure out how to have pluggable authorization
  # handlers.  What should happen if the authorization type is
  # Basic?  Other types: Cookie?
  credential: (type, action) ->
    if type == "Capability"
      @properties.capabilities[action]

module.exports = Client
