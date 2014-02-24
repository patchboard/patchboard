URL = require("url")
Context = require("./context")

class SimpleDispatcher

  constructor: (@service, @handlers) ->
    handler = @handlers.service.default

    for resource, definition of @service.resources
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= handler

  request_listener: () ->
    (request, response) =>
      @dispatch(request, response)

  dispatch: (request, response) ->
    @service.augment_request(request)
    match = @service.classify(request)
    if match.error?
      @error_handler(match.error, response)
    else
      handler = @find_handler(match)
      context = new Context(@service, request, response, match)
      handler(context)

  find_handler: (match) ->
    if !(resource = @handlers[match.resource_type])?
      throw "No such resource: #{match.resource_type}"

    if !(action = resource[match.action_name])?
      throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"

    action

  error_handler: (error, response) ->
    response.setHeader "Access-Control-Allow-Origin", "*"

    response.writeHead error.status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error, null, 2)



module.exports = SimpleDispatcher
