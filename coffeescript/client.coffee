Shred = require("shred")

#string = fs.readFileSync("../rigger-schema.json")
#rigger_schema = JSON.parse(string)
rigger_schema = require("../rigger-schema")

class Client

  constructor: (@service_url, options) ->
    @shred = new Shred()
    @resources = {}
    @schema =
      rigger: rigger_schema
      resources: options.schema
    @interface = options.interface

    rigger = @

    for resource_name, schema_def of @schema.resources
      @generate_resource_class(resource_name, schema_def)


  generate_resource_class: (resource_name, schema_def) ->
    rigger = @
    interface_def = @interface[resource_name]
    @resources[resource_name] = class extends Resource
      @resource_name = resource_name

      constructor: (properties) ->
        @rigger = rigger
        @properties = properties
        if @wrap_data
          @properties = @wrap_data(@properties)

      @process_schema(rigger, schema_def)

      if interface_def
        try
          @process_interface(interface_def)
        catch e
          console.log(resource_name, schema_def, interface_def)
          throw e

  wrap: (type, data) ->
    console.log("wrapping with", type)
    if klass = @resources[type]
      new klass(data)
    else
      data


class Resource

  @process_interface: (definition) ->
    for action_name, action_def of definition.actions
      @define_action(action_name, action_def)

  @process_schema: (rigger, definition) ->
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
        # when we see a property that is not a primitive type,
        # we need to define a wrapper class for it.  So that the
        # rigger.wrap method will be able to find the correct
        # class, we change the type name to the property name.
        # Skeezy, but should be obviated by a real schema handler.
        if prop_def.type == "object"
          prop_def.type = property_name
          rigger.generate_resource_class(property_name, prop_def)
        @simple_property(property_name, prop_def)

  @simple_property: (property_name, definition) ->
    spec = {}
    spec["get"] = @define_getter(property_name, definition)
    if !definition.readonly
      spec["set"] = (val) ->
        @properties[property_name] = val
    Object.defineProperty @prototype, property_name, spec

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
  @define_getter: (name, definition) ->
    type = definition.type
    props = definition.properties
    () ->
      console.log("getter for", name, type)
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
