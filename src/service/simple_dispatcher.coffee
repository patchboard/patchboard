Classifier = require("./classifier")
Context = require("./context")

class SimpleDispatcher

  constructor: (@service, @handlers) ->
    @schema = service.schema
    @http_interface = service.interface
    @map = service.map
    @supply_missing_handlers()

    @classifier = new Classifier(@service)

  supply_missing_handlers: () ->
    handler = @handlers.meta.default

    for resource, definition of @http_interface
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= handler

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

  find_handler: (match) ->
    if resource = @handlers[match.resource_type]
      if action = resource[match.action_name]
        action
      else
        throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"
    else
      throw "No such resource: #{match.resource_type}"

  classification_error: (error, request, response) ->
    @default_error_handler(error, response)

  default_error_handler: (error, response) ->
    response.writeHead error.status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error)



module.exports = SimpleDispatcher
