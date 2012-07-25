Classifier = require("./classifier")

class SimpleDispatcher

  constructor: (@service, @handlers) ->
    @schema = service.schema
    @http_interface = service.interface
    @map = service.map
    @install_default_handlers()
    @supply_missing_handlers()

    @classifier = new Classifier(@service)

  install_default_handlers: () ->
    service = @service
    service_description =
      interface: service.interface
      schema: service.schema

    @handlers.meta.service_description ||= (context) ->
      {request, response, match} = context

      content = JSON.stringify(service_description)
      headers =
        "Content-Type": "application/json"
        "Content-Length": content.length
      response.writeHead 200, headers
      response.end(content)

    @handlers.meta.documentation ||= (context) ->
      {request, response, match} = context

      content = service.documentation()
      headers =
        "Content-Type": "text/plain"
        "Content-Length": content.length
      response.writeHead 200, headers
      response.end(content)

  supply_missing_handlers: () ->
    dummy_handler = (context) ->
      {request, response, match} = context

      content = JSON.stringify
        message: "Unimplemented: #{match.resource_type}.#{match.action_name}"
      headers =
        "Content-Type": "application/json"
        "Content-Length": content.length
      response.writeHead 501, headers
      response.end(content)

    for resource, definition of @http_interface
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= dummy_handler

  class Context
    constructor: (@request, @response, @match) ->

  create_handler: () ->
    dispatcher = @
    (request, response) ->
      dispatcher.dispatch(request, response)

  dispatch: (request, response) ->
    result = @classifier.classify(request)
    if result.error
      @classification_error(result.error, request, response)
    else
      handler = @find_handler(result)
      context = new Context(request, response, result)
      handler(context)

  classification_error: (error, request, response) ->
    @default_error_handler(error, response)

  find_handler: (match) ->
    if resource = @handlers[match.resource_type]
      if action = resource[match.action_name]
        action
      else
        throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"
    else
      throw "No such resource: #{match.resource_type}"

  default_error_handler: (error, response) ->
    response.writeHead error.status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error)



module.exports = SimpleDispatcher
