URL = require("url")
Context = require("../context")

module.exports = class SimpleDispatcher

  constructor: (@service, @handlers) ->
    for resource, actions of @service.default_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    missing = @handlers.service.default

    for resource, definition of @service.resources
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= missing

  request_listener: () ->
    (request, response) =>
      @dispatch(request, response)

  dispatch: (request, response) ->
    context = new Context @service, request, response
    if context.match.error?
      body = JSON.stringify(context.match.error, null, 2)
      response.setHeader "Access-Control-Allow-Origin", "*"
      response.setHeader "Content-Length", Buffer.byteLength(body)
      response.writeHead context.match.error.status,
        "Content-Type": "application/json"
      response.end JSON.stringify(context.match.error, null, 2)
    else
      @find_handler(context.match)(context)

  find_handler: (match) ->
    if !(resource = @handlers[match.resource_type])?
      throw "No such resource: #{match.resource_type}"

    if !(action = resource[match.action_name])?
      throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"

    action



