Shred = require("shred")

class Client

  constructor: (@service_url, options) ->
    @shred = new Shred()
    @resources = {}
    @schema = options.schema
    @interface = options.interface
    @assemble_interface(@interface)

  assemble_interface: (interface) ->
    for resource, definition of interface
      @assemble_resource(resource, definition)

  assemble_resource: (resource_name, definition) ->
    rigger = @
    shred = @shred
    schema = @schema
    @resources[resource_name] = class extends Resource
      @name = resource_name
      constructor: (@properties) ->
        @rigger = rigger
        @shred = shred
        @schema = schema

        @url = properties.url
      @setup(resource_name, definition)
  

class Resource
  constructor: () ->

  @setup: (resource_name, definition) ->
    for action_name, action_def of definition.actions
      @define_action(action_name, action_def)

  @define_action: (action_name, definition) ->
    @prototype[action_name] = (data) ->
      rigger = @rigger
      callback = data.callback
      delete data.callback

      request = {}
      request.headers = headers = {}

      request_type = definition.request_schema
      response_type = definition.response_schema
      headers = {}
      if request_type
        headers["Content-Type"] = @schema[request_type].media_type
      if response_type
        headers["Accept"] = @schema[response_type].media_type
      if definition.authorization
        cap = @properties.capabilities[action_name]
        headers["Authorization"] = "Capability #{cap}"


      @shred.request
        url: @url
        method: definition.method
        headers: headers
        content: data
        on:
          response: (response) ->
            console.log("Success!")
            callback(response.content.data)
          error: (r) ->
            console.log "whoops"


module.exports = Client
